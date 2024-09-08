@echo off
doskey graph= git log --decorate --graph --oneline --all
doskey gadd=git add .
doskey commit=git commit
doskey lspe=dir *.exe 
doskey close=cd ..
doskey clearbuild= cls ^&^& ninja
doskey new= start cmd


mkdir build
cd build 
doskey configure=cmake .. -G Ninja -DBUILD_SHARED_LIBS=FALSE
cmake .. -G Ninja -DBUILD_SHARED_LIBS=FALSE
ninja


@echo on
