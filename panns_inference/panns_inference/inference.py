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
    def __init__(self, model=None, checkpoint_path=None,checkpoint_model=None, device='cuda'):
        """Audio tagging inference wrapper.
        """
        if not checkpoint_path:
            checkpoint_path= "/content/drive/My Drive/SonART/saved_model/panns/Cnn14_mAP=0.431.pth"
        print('Checkpoint path: {}'.format(checkpoint_path))


        checkpoint_dir = os.path.dirname(checkpoint_path)  # Ottieni la directory del file

        # Verifica se la cartella esiste, altrimenti la crea
        if not os.path.exists(checkpoint_dir):
            print(f"🔄 La cartella non esiste. Creando la cartella: {checkpoint_dir}")
            os.makedirs(checkpoint_dir, exist_ok=True)
        else:
            print(f"✅ La cartella esiste già: {checkpoint_dir}")
            
        # Procedi con il download
        if not os.path.exists(checkpoint_path) or os.path.getsize(checkpoint_path) < 3e8:
            print("⚠️ File non trovato o corrotto. Scarico il modello...")
            
            zenodo_path = "https://zenodo.org/record/3987831/files/Cnn14_mAP%3D0.431.pth?download=1"
            
            # Scarica il modello
            os.system(f'wget -O "{checkpoint_path}" "{zenodo_path}"')

            # Controlla la dimensione del file
            if os.path.exists(checkpoint_path):
                file_size = os.path.getsize(checkpoint_path) / (1024 * 1024)  # Converti in MB
                if file_size < 300:
                    print(f"⚠️ Attenzione: il file è troppo piccolo ({file_size:.2f} MB), potrebbe essere corrotto!")
                else:
                    print(f"✅ File scaricato correttamente ({file_size:.2f} MB)")
            else:
                raise FileNotFoundError("❌ Errore: il file non è stato scaricato. Controlla la connessione.")
        else:
            print("✅ Il file esiste già, nessun download necessario.")


        if device == 'cuda' and torch.cuda.is_available():
            self.device = 'cuda'
        else:
            self.device = 'cpu'
        
        self.labels = labels
        self.classes_num = classes_num

        # Model
        if model is None:
            self.model = Cnn14(sample_rate=32000, window_size=1024, 
                hop_size=320, mel_bins=64, fmin=50, fmax=14000, 
                classes_num=self.classes_num)
            
            checkpoint = torch.load(checkpoint_path, map_location=self.device)
            self.model.load_state_dict(checkpoint['model'])

            if checkpoint_model is None:
                checkpoint_model = "/content/drive/My Drive/SonART/saved_model/panns/panns_model.pth"

            torch.save(self.model, checkpoint_model)
            print(f"💾 Modello istanziato salvato su Drive: /content/drive/My Drive/SonART/saved_model/panns/panns_model.pth")
        else:
            self.model = model
            print("Il modello esiste già!")


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
    def __init__(self, model=None, checkpoint_path=None,checkpoint_model=None, device='cuda', interpolate_mode='nearest'):
        """Sound event detection inference wrapper.

        Args:
            model: None | nn.Module
            checkpoint_path: str
            device: str, 'cpu' | 'cuda'
            interpolate_mode, 'nearest' |'linear'
        """
        if not checkpoint_path:
            checkpoint_path="/content/drive/My Drive/SonART/saved_model/panns/Cnn14_DecisionLevelMax.pth"
        print('Checkpoint path: {}'.format(checkpoint_path))


        checkpoint_dir = os.path.dirname(checkpoint_path)  # Ottieni la directory del file

        # Verifica se la cartella esiste, altrimenti la crea
        if not os.path.exists(checkpoint_dir):
            print(f"🔄 La cartella non esiste. Creando la cartella: {checkpoint_dir}")
            os.makedirs(checkpoint_dir, exist_ok=True)
        else:
            print(f"✅ La cartella esiste già: {checkpoint_dir}")
            
        # Procedi con il download
        if not os.path.exists(checkpoint_path) or os.path.getsize(checkpoint_path) < 3e8:
            print("⚠️ File non trovato o corrotto. Scarico il modello...")
            
            zenodo_path = "https://zenodo.org/record/3987831/files/Cnn14_DecisionLevelMax_mAP%3D0.385.pth?download=1"

            
            # Scarica il modello
            os.system(f'wget -O "{checkpoint_path}" "{zenodo_path}"')

            # Controlla la dimensione del file
            if os.path.exists(checkpoint_path):
                file_size = os.path.getsize(checkpoint_path) / (1024 * 1024)  # Converti in MB
                if file_size < 300:
                    print(f"⚠️ Attenzione: il file è troppo piccolo ({file_size:.2f} MB), potrebbe essere corrotto!")
                else:
                    print(f"✅ File scaricato correttamente ({file_size:.2f} MB)")
            else:
                raise FileNotFoundError("❌ Errore: il file non è stato scaricato. Controlla la connessione.")
        else:
            print("✅ Il file esiste già, nessun download necessario.")

        #if not os.path.exists(checkpoint_path) or os.path.getsize(checkpoint_path) < 3e8:
            #create_folder(os.path.dirname(checkpoint_path))
            #os.system('wget -O "{}" https://zenodo.org/record/3987831/files/Cnn14_DecisionLevelMax_mAP%3D0.385.pth?download=1'.format(checkpoint_path))

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

            checkpoint = torch.load(checkpoint_path, map_location=self.device)
            self.model.load_state_dict(checkpoint['model'])

            if checkpoint_model is None:
                checkpoint_model = "/content/drive/My Drive/SonART/saved_model/panns/panns_model_event_det.pth"


            torch.save(self.model, checkpoint_model)
            print(f"💾 Modello istanziato salvato su Drive: /content/drive/My Drive/SonART/saved_model/panns/panns_model_event_det.pth")
        else:
            self.model = model
            print("Il modello esiste già!")
        

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
