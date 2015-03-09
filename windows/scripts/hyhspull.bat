    echo "Pushing from Hyrule"
    ssh -t cralljp@linux.cs.rpi.edu "ssh -t joncrall@hyrule.cs.rpi.edu \"cd %CODE_DIR%/hotspotter; git commit -am "hyhs wip"; git push\""
    
    echo "Pulling from Local"
    git pull