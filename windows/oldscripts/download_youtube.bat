cls
cd %code%\youtube-dl
youtube-dl --help
youtube-dl --dump-user-agent


youtube-dl --match-title ".*: *Crash Course Chemistry #[0-9]*" --max-downloads 50 
youtube-dl --list-extractors

set CRASH_COURSE_PLAYLIST="http://www.youtube.com/watch?v=FSyAehMdpyI&list=PL8dPuuaLjXtPHzzYuWy6fYEaX9mQQ8oGr"
youtube-dl --playlist-start 1 --playlist-end 30 %CRASH_COURSE_PLAYLIST%

youtube-dl --match-title ".*: *Crash Course Chemistry #[0-9]*" YouTube.com
youtube-dl http://www.youtube.com/watch?v=FSyAehMdpyI
youtube http://www.youtube.com/watch?v=hQpQ0hxVNTg
youtube http://www.youtube.com/watch?v=QiiyvzZBKT8
youtube http://www.youtube.com/watch?v=0RRVV4Diomg


youtube-dl --match-title "The 4 Most Irreplaceable Places" YouTube.com

https://www.youtube.com/playlist?list=PL8dPuuaLjXtOeEc9ME62zTfqc0h6Pe8vb
youtube-dl.exe --playlist-start 1 --playlist-end 28 https://www.youtube.com/watch?v=MSYw502dJNY&list=PL8dPuuaLjXtOeEc9ME62zTfqc0h6Pe8vb

youtube-dl.exe -citk --playlist-start 1 --playlist-end 28 https://www.youtube.com/playlist?list=PL8dPuuaLjXtOeEc9ME62zTfqc0h6Pe8vb


youtube-dl.exe -citk https://www.youtube.com/watch?v=ugqu10JV7dk
youtube-dl.exe -citk https://www.youtube.com/watch?v=RR2sX8tFGsI
youtube-dl.exe -citk https://www.youtube.com/watch?v=QjXJLVINsSA
