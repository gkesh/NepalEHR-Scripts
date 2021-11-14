#! /bin/bash

# Print with seperator
print_with_sep() {
    echo "====================================================="
    echo "$1"
    echo "====================================================="
}

# Installing required yum packages
print_with_sep "Installing pre-requisitie yum packages"

# List of yum packages to be installed
yumdeps=("-y https://kojipkgs.fedoraproject.org//packages/zlib/1.2.11/19.fc30/x86_64/zlib-1.2.11-19.fc30.x86_64.rpm" "epel-release" "python-pip" "python-psycogreen")
for dep in "${yumdeps[@]}"; do
    sudo yum install $dep
    if [ $? -eq 0 ]; then
        print_with_sep "Pre-requisite installed Successfully"
    else
        print_with_sep "Issue in installation, confirm if installed!"
    fi
done

# Checking if click is installed
sudo python3 -c "import click"
if [ $? -eq 0 ]; then
    print_with_sep "Click installation found in system, removing...."
    sudo pip uninstall click
    if [ $? -eq 0 ]; then
    	print_with_sep "Click successfully uninstalled"
    else
        print_with_sep "Failed to uninstall Click, please check further."
        exit 1
    fi
else
    print_with_sep "Click not found in system, moving on..."
fi

# List of pip packages to be installed
pipdeps=("pip==v19.0" "click==v7.0" "pyusb" "babel==v1.0.0" "decorator==v3.4.0" "beautifulsoup4" "psycopg2-binary" "ofxparse" "python-chart" "requests" "passlib" "qrcode" "xlsxwriter" "python-stdnum" "pyserial" "pypdf")
for dep in "${pipdeps[@]}"; do
    print_with_sep "Installing with pip: $dep"
    sudo pip install $dep
    if [ $? -eq 0 ]; then
        print_with_sep "Successfully installed: $dep"
    else
        print_with_sep "Some issue with installation: $dep"
    fi
done

# Installing Bahmni CLI, check version
print_with_sep "Installing Bahmni CLI"

yum install  http://repo.mybahmni.org/releases/bahmni-installer-0.92-155.noarch.rpm
if [ $? -eq 0]; then
    echo "You are ready to install bahmni, try 'bahmni --help'"
else
    echo "Something went wrong, please check!"
    exit 1
fi
