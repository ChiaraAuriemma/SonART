# SonART

<p align="center">
  <img src="deliveries/Logo3.jpg" alt="SonART logo" width="600">
</p>


## Group:

| Name            | GitHub                                              | Student ID | Email                          |
|-----------------|-----------------------------------------------------|------------|--------------------------------|
| Chiara Auriemma | [@ChiaraAuriemma](https://github.com/ChiaraAuriemma) | 10722613   | chiara.auriemma@mail.polimi.it |
| Matteo Benzo    | [@Teobenzo](https://github.com/Teobenzo)           | 10705157   | matteo.benzo@mail.polimi.it    |
| Anna Fusari     | [@AnnaFusari](https://github.com/AnnaFusari)       | 10561236   | anna.fusari@mail.polimi.it     |
| Diego Pini      | [@DiegoPini](https://github.com/DiegoPini)         | 10668724   | diego.pini@mail.polimi.it      |



## Description:
SonART is an application designed to help people with limited resources bring their performances to life, enhancing them through an original technology.

The user can upload an audio track they intend to use during their performance, and SonART will classify the sounds it contains and transform them into images that are always unique, thanks to the generative AI. These visuals will appear on screen in sync with the sounds they represent. To make the experience even more visually engaging, a custom Processing script modifies the images to give them a unique artistic flair. The user experience is simplified through a built-in GUI within the notebook, guiding users through the file upload and processing steps. The GUI also allows customization of certain parameters to improve the final result.

<details>
<summary>read more</summary>
  
While the application works also with musical tracks and instruments, it is primarily designed to accompany theatrical performances, where environmental or narrative-driven sounds are used. In this context, SonART generates dynamic visual backdrops. This is one of the system’s key features, distinguishing it from other applications that are mainly intended to accompany musical performances.

Although this was the original concept that inspired the project, SonART also lends itself to more playful or educational purposes: “Aren’t you curious to see how that track will be transformed?” It can help children associate sounds with images in a fun way, enhance storytelling during a Dungeons & Dragons session by preparing sounds and letting SonART handle the visuals, or even make performances more inclusive for the hearing impaired. You can also use it during relaxation sessions, pairing nature sounds with beautiful, evolving imagery.

In short, the only limit is your creativity.

</details>

## How to use:
#### 📂 Google Drive setup:
To use the application, you need to set up your Google Drive. This operation only needs to be done once, and after that, you’ll be ready to use the application anytime you want:

1. Upload the SonART_setup folder from the repository to your Google Drive.

---

#### 🌐 ngrok setup: 
Since Google Colab cannot directly access local servers due to network restrictions, ngrok acts as a secure tunnel that bridges our Processing sketch, running locally, to the Colab notebook. 
1. Go to https://ngrok.com/download and download the version for your operating system.
2. Sign up at https://dashboard.ngrok.com/signup and log in. You’ll be asked to provide a credit card number for identity verification purposes, but don’t worry — the service is completely free.
3. Search for your Authtoken in your dashboard, andy copy it.
4. Configure ngrok by running the following in your terminal: ngrok config add-authtoken YOUR_AUTHTOKEN
6. Start a tunnel by running: ngrok http 1234
7. You’ll see a public URL like https://xxxx.ngrok.io that forwards to your local service.

NOTA : l'ultimo punto è da rivedere perchè aggiungendo la parte automatica lo fa da solo. 

---

#### 🎛️ Use the application:
1. Open the file SonART_code.ipynb on Google Colab.
2. In the Processing connection section, enter the address and port.
3. Run all the cells in the "Run for setup" section.
4. You will be asked to grant access to Google Drive, please authorize it.
5. Run the "GUI" section and upload an audio file through the GUI.
6. Open the Processing script and run it.
7. Use the Play button in the GUI.

----

#### 🧠 Some additional tips:
<details>
<summary>read more</summary>
  
- The application allows you to upload and process in advance all the files you need for your performance. Our advice is to prepare them all beforehand and then play them in the order you prefer using the play button.
- During the processing of an audio file, the identified classes, the probability assigned to each class by the classifier, and the timestamps will be printed on screen. The generated images can be viewed through the Colab file system.
- If you don't like the results obtained, you can always delete them through the GUI and try again with different parameters.
- To improve the results, you have the option to ban certain labels in order to encourage the recognition of more specific ones.
- You can also choose to use the threshold parameter. The idea is that if you set a high threshold, you'll get fewer labels in the output, with the risk of having no output in certain segments — but the results you do get will be more stable and reliable. With a low threshold, the opposite happens: the system becomes more responsive but less accurate.
- Remember to include background and style to customize the generated images.
- If you notice that it takes a bit of time to run the cells in 'Run for setup', don’t worry! That’s perfectly normal, especially the very first time you try the application, as the audio model needs to be created from scratch and loaded onto your drive. You’ll see that next time, the code will run much faster.

</details>


## References:
#### Audio part:
- Qiuqiang Kong, Yin Cao, Turab Iqbal, Yuxuan Wang, Wenwu Wang, Mark D. Plumbley. "PANNs: Large-Scale Pretrained Audio Neural Networks for Audio Pattern Recognition." arXiv preprint arXiv:1912.10211 (2019)
- https://github.com/qiuqiangkong/panns_inference/tree/master
- https://github.com/qiuqiangkong/audioset_tagging_cnn?tab=readme-ov-file
- https://github.com/yinkalario/Sound-Event-Detection-AudioSet/tree/master

#### Images part:
- https://huggingface.co/latent-consistency/lcm-lora-sdxl
