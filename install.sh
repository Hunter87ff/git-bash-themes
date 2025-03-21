# make sure to run this script with git bash or bash shell
mkdir -p $HOME/.bash/themes #it'll be something like this C:/Users/<user>/.bash/themes
THEME_PATH=$HOME/.bash/themes/theme1.bash #for different theme, change the theme1.bash to another theme name
cp ./themes/theme1.bash $THEME_PATH

#install the theme
rm -f ~/.bashrc #if you want to keep the old .bashrc, remove/comment this line
echo -e "source ${THEME_PATH}" >> ~/.bashrc
source ~/.bashrc