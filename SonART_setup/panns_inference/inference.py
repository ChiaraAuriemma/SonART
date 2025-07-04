import os
import numpy as np
import argparse
import librosa
import matplotlib.pyplot as plt
import torch
from pathlib import Path

from .pytorch_utils import move_data_to_device
from .models import Cnn14, Cnn14_DecisionLevelMax
from .config import labels, classes_num


def create_folder(fd):
    if not os.path.exists(fd):
        os.makedirs(fd)
        
        
def get_filename(path):
    path = os.path.realpath(path)
    na_ext = path.split('/')[-1]
    na = os.path.splitext(na_ext)[0]
    return na


class AudioTagging(object):
    def __init__(self, checkpoint_path=None,checkpoint_model=None, device='cuda'):
        """Audio tagging inference wrapper.
        Args:
            checkpoint_path: str, path to the model weights
            checkpoint_model: str, path to the model file
            device: str, 'cpu' | 'cuda'
        """
        if not checkpoint_path:
            checkpoint_path = os.path.join("/content/drive/My Drive/SonART_setup","saved_model", "Cnn14_mAP=0.431.pth")
        print('Checkpoint path: {}'.format(checkpoint_path))

            
        # Proceed with download
        if not os.path.exists(checkpoint_path) or os.path.getsize(checkpoint_path) < 3e8:
            print("⚠️ File not found or corrupt. Downloading weights...")
            
            os.makedirs(os.path.dirname(checkpoint_path), exist_ok=True)
            
            zenodo_path = "https://zenodo.org/record/3987831/files/Cnn14_mAP%3D0.431.pth?download=1"
            
            os.system(f'wget -O "{checkpoint_path}" "{zenodo_path}"')

            # Check file size
            if os.path.exists(checkpoint_path):
                file_size = os.path.getsize(checkpoint_path) / (1024 * 1024)  
                if file_size < 300:
                    print(f"⚠️ Warning: the file is too small ({file_size:.2f} MB), it might be corrupted!")
                    raise FileNotFoundError("❌ Error: File not downloaded. Check your connection.")
                else:
                    print(f"✅ File downloaded successfully ({file_size:.2f} MB)")
            else:
                raise FileNotFoundError("❌ Error: File not downloaded. Check your connection.")
        else:
            print("✅ File already exists, no download needed.")


        if device == 'cuda' and torch.cuda.is_available():
            self.device = 'cuda'
        else:
            self.device = 'cpu'
        
        self.labels = labels
        self.classes_num = classes_num


        # Set default path if checkpoint_model not provided
        if checkpoint_model is None:
            checkpoint_model = os.path.join("/content/drive/My Drive/SonART_setup","saved_model", "panns_model.pth")
            print('Checkpoint model: {}'.format(checkpoint_model))

        # Model
        if os.path.exists(checkpoint_model):
            # The saved model already exists: load it
            self.model = torch.load(checkpoint_model, map_location=self.device, weights_only=False)
            print(f"✅ Model uploaded by: {checkpoint_model}")
        else:
            # The file does not exist: create and save the model
            print(f"⚠️ Model not found. Creating a new model...")

            self.model = Cnn14(sample_rate=32000, window_size=1024, 
                hop_size=320, mel_bins=64, fmin=50, fmax=14000, 
                classes_num=self.classes_num)

            checkpoint = torch.load(checkpoint_path, map_location=self.device)
            self.model.load_state_dict(checkpoint['model'])

            os.makedirs(os.path.dirname(checkpoint_model), exist_ok=True)
            torch.save(self.model, checkpoint_model)

            print(f"💾 New model saved in: {checkpoint_model}")


        # Parallel
        if 'cuda' in str(self.device):
            self.model.to(self.device)
            print('GPU number: {}'.format(torch.cuda.device_count()))
            self.model = torch.nn.DataParallel(self.model)
        else:
            print('Using CPU.')

    def inference(self, audio):
        audio = move_data_to_device(audio, self.device)

        with torch.no_grad():
            self.model.eval()
            output_dict = self.model(audio, None)

        clipwise_output = output_dict['clipwise_output'].data.cpu().numpy()
        embedding = output_dict['embedding'].data.cpu().numpy()

        return clipwise_output, embedding



class SoundEventDetection(object):
    def __init__(self, model=None, checkpoint_path=None, device='cuda', interpolate_mode='nearest'):
        """Sound event detection inference wrapper.

        Args:
            model: None | nn.Module
            checkpoint_path: str
            device: str, 'cpu' | 'cuda'
            interpolate_mode, 'nearest' |'linear'
        """
        if not checkpoint_path:
            checkpoint_path='{}/panns_data/Cnn14_DecisionLevelMax.pth'.format(str(Path.home()))
        print('Checkpoint path: {}'.format(checkpoint_path))

        if not os.path.exists(checkpoint_path) or os.path.getsize(checkpoint_path) < 3e8:
            create_folder(os.path.dirname(checkpoint_path))
            os.system('wget -O "{}" https://zenodo.org/record/3987831/files/Cnn14_DecisionLevelMax_mAP%3D0.385.pth?download=1'.format(checkpoint_path))

        if device == 'cuda' and torch.cuda.is_available():
            self.device = 'cuda'
        else:
            self.device = 'cpu'
        
        self.labels = labels
        self.classes_num = classes_num

        # Model
        if model is None:
            self.model = Cnn14_DecisionLevelMax(sample_rate=32000, window_size=1024, 
                hop_size=320, mel_bins=64, fmin=50, fmax=14000, 
                classes_num=self.classes_num, interpolate_mode=interpolate_mode)
        else:
            self.model = model
        
        checkpoint = torch.load(checkpoint_path, map_location=self.device)
        self.model.load_state_dict(checkpoint['model'])

        # Parallel
        if 'cuda' in str(self.device):
            self.model.to(self.device)
            print('GPU number: {}'.format(torch.cuda.device_count()))
            self.model = torch.nn.DataParallel(self.model)
        else:
            print('Using CPU.')

    def inference(self, audio):
        audio = move_data_to_device(audio, self.device)

        with torch.no_grad():
            self.model.eval()
            output_dict = self.model(
                input=audio, 
                mixup_lambda=None
            )

        framewise_output = output_dict['framewise_output'].data.cpu().numpy()

        return framewise_output
