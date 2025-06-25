# SonART

<p align="center">
  <em>“Every sound tells a story. We make sure it’s seen.”</em><br>
</p>

<p align="center">
    <img src="deliveries/Logo2.png" alt="alt text">
</p>

## Group:

- ####  Chiara Auriemma &nbsp;([@ChiaraAuriemma](https://github.com/ChiaraAuriemma))<br> 10722613&nbsp;&nbsp; chiara.auriemma@mail.polimi.it
- ####  Matteo Benzo &nbsp;([@Teobenzo](https://github.com/Teobenzo))<br> 10705157&nbsp;&nbsp; matteo.benzo@mail.polimi.it
- ####  Anna Fusari &nbsp;([@AnnaFusari](https://github.com/AnnaFusari))<br> 10561236&nbsp;&nbsp; anna.fusari@mail.polimi.it
- ####  Diego Pini &nbsp;([@DiegoPini](https://github.com/DiegoPini))<br> 10668724&nbsp;&nbsp; diego.pini@mail.polimi.it

## Description:
SonART is an application designed to help artists with limited resources bring their performances to life, enhancing them through an original technology.

The artist can upload an audio track they intend to use during their performance, and SonART will classify the sounds it contains and transform them into images that are always unique, thanks to the generative AI. These visuals will appear on screen in sync with the sounds they represent. To make the experience even more visually engaging, a custom Processing script modifies the images to give them a unique artistic flair. The user experience is simplified through a built-in GUI within the notebook, guiding users through the file upload and processing steps. The GUI also allows customization of certain parameters to improve the final result.

While the application works also with musical tracks and instruments, it is primarily designed to accompany theatrical performances, where environmental or narrative-driven sounds are used. In this context, SonART generates dynamic visual backdrops. This is one of the system’s key features, distinguishing it from other applications that are mainly intended to accompany musical performances.

Although this was the original concept that inspired the project, SonART also lends itself to more playful or educational purposes: “Aren’t you curious to see how that track will be transformed?” It can help children associate sounds with images in a fun way, enhance storytelling during a Dungeons & Dragons session by preparing sounds and letting SonART handle the visuals, or even make performances more inclusive for the hearing impaired. You can also use it during relaxation sessions, pairing nature sounds with beautiful, evolving imagery.

In short, the only limit is your creativity.

## How to use:
### Google Drive setup:
To use the application, you need to set up your Google Drive. This operation only needs to be done once, and after that, you’ll be ready to use the application anytime you want:

1. In your Google Drive, create a folder named SonART.
2. Inside the SonART folder, create a subfolder named Code.
3. In the Code folder, upload the panns-inference folder found in the repository.
4. Create a folder named saved_model.
5. Upload the files filterable_labels.json and labels_config.json (both available in the repository) into the SonART folder.

### ngrok setup:

### Use the application:
1. Open the file SonART_code.ipynb on Google Colab.
2. In the Processing connection section, enter the address and port.
3. Run all the cells in the "Run for setup" and "GUI" sections.
4. Upload an audio file through the GUI.
5. Open the Processing script and run it.
6. Use the Play button in the GUI.

## References:
### Audio part:
- Qiuqiang Kong, Yin Cao, Turab Iqbal, Yuxuan Wang, Wenwu Wang, Mark D. Plumbley. "PANNs: Large-Scale Pretrained Audio Neural Networks for Audio Pattern Recognition." arXiv preprint arXiv:1912.10211 (2019)
- https://github.com/qiuqiangkong/panns_inference/tree/master
- https://github.com/qiuqiangkong/audioset_tagging_cnn?tab=readme-ov-file
- https://github.com/yinkalario/Sound-Event-Detection-AudioSet/tree/master

### Image part:
- https://huggingface.co/latent-consistency/lcm-lora-sdxl
