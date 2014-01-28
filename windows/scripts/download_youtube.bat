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

