# https://help.github.com/articles/configuring-a-remote-for-a-fork/


git remote -v
git remote add abramhindle https://github.com/abramhindle/flann.git
git remote -v
git fetch abramhindle

git checkout merge_addpoints_bindings
git merge abramhindle/master

git merge origin/master


gvim src/cpp/flann/flann.h


# now push this to my fork
git remote add Erotemic git@github.com:Erotemic/flann.git
#git remote add Erotemic https://github.com/Erotemic/flann.git
git push Erotemic
