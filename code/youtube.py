import shutil
import os
os.mkdir(r'C:\Users\jon.crall\code\youtube-dl')
os.chdir(r'C:\Users\jon.crall\code\youtube-dl')
import youtube_dl 
params = {}
y = youtube_dl.YoutubeDL(params)

youtube-dl "http://www.youtube.com/watch?v=FSyAehMdpyI"
url='http://www.youtube.com/watch?v=FSyAehMdpyI'
url_list = [url]
y.download(url_list)

