#usr/bin/bash
#Please note that certain functions may seem disorganized. But that is to comply with bash rules (Without which the script would not run).
usageFunc (){
	#This function is to guide the user about the usage of the script. It is invoked everytime user goes wrong as well, in order to correct him/her.
	echo "======================================================================================================================================================="
	echo "Ihsan's Encryptor Usage."
	echo "+++++++++++++++++++++++++"
	echo "Enter Space seperated arguments corresponding to your needs. (You may run the script without arguments as well. Arguments are for quicker access)"
	echo -e "\nFor Symmetric Encyptions: ./IhsanEncryptor.sh enc <Encyption Algorithm> <directory path>"
	echo "Availalble Encyption algorithms are ( All except des3 and rc4 are cbc algorithms ): bf, rc2, rc4, des, des3, aes-128, aes-192, aes-256"
	echo "Please note that entering and verifying passwords are mandatory for symmetric encryption"
	echo -e "\nFor Decrypting symmetric Encryptions : ./IhsanEncryptor dec <Encyption Algorithm> <Encrypted file path>"
	echo -e "\nFor Generating Asymmetric key-pairs: ./IhsanEncryptor asgen"
	echo -e "\nFor Asymmetric Encryptions : ./IhsansEncryptor asenc <Path to .pem file with public key> <directory path>"
	echo -e "\nFor Asymmetric Decryptions : ./IhsansEncryptor asdec <Path to .pem file with private key>  <path to file>"
	echo -e "\nFor Signing : ./IhsansEncryptor sign <Path to .pem file with private key> <directory to sign>"
	echo -e "\nFor verifying signed file : ./IhsansEncryptor ver <Path to ver .pem file with public key> <path to file>"
	echo -e "\nFor Generating hash : ./IhsanEncryptor hash <Hashing Algorithm> <path to file>"
	echo "Hashing algorithms availalble :md5 sha1 sha256"
	echo -e "\nFor more help please visit https://www.alphagreytux.wordpress.com\n"
}

symEnc(){
	#This function handles symmetric encryptions. It requires 2 inputs from the user : Directory to encrypt and algorithm
	#Here a file is unique filename is used to avoid overwriting an existing file. (Using epoch time).
	#Users MUST enter a password while encrypting and verify it.
	#The directory is also compressed to the max amount upon encryption in order to save space.
	if [ -d $2 ];then
		echo "Encrypt ${2} using ${1}? Enter y/n"
		read ch
		if [ $ch='y' ];then
			temp=`echo $(date +%s)`
			tar -cvf ${temp}.tar ${2} > /dev/null
			gzip -9 ${temp}.tar
			openssl enc -${1} -e -in ${temp}.tar.gz -out ${temp}encrypted -md md5
			st=$?
			rm -rf ${temp}.tar.gz
			if [ $st -eq 0 ];then
				echo "Encyption complete! Encrypted file is : ${temp}encrypted"
			else
				echo "There was some problem. Could not encrypt directory."
			fi
			sleep 7
			disp
			showMenu
			else
				disp
				showMenu
		fi
	else
		disp
		echo "Invalid directory! Please Re-Enter."
		showMenu
	fi

}

symDec(){
	#This function handles symmertic decryption. User needs to enter the path to the encrypted file encrypted and the algorithm used to encrypt the file.
	#Similar to the encryption function, this will create a unique directory as the output. Users must enter the password when prompted while decrypting.
	#This does the reverse process of encryption and decompresses directories upon decryption.
	echo "Decrypting $2 using $1 algorithm."
	if [ -f $2 ];then
		temp=`echo $(date +%s)`
		openssl enc -${1} -d -in ${2} -out ${temp}dec.tar.gz
		st=$?
		gunzip ${temp}dec.tar.gz
		mkdir ${temp}dec
		mv ${temp}dec.tar ./${temp}dec
		cd ${temp}dec
		tar -xvf ${temp}dec.tar > /dev/null
		cd ..
		rm -rf ./${temp}dec/${temp}dec.tar
		if [ $st -eq 0 ];then 
			echo "Decryption complete! Decrypted directory is : ${temp}dec"
		else
			echo "There was some problem. Could not decrypt."
		fi
		sleep 7
		disp
		showMenu
	else
		disp
		echo "Invalid path to file! Please Re-Enter."
		showMenu
	fi
}

asGen(){
	#This function is resposible of generating RSA public and private keys.
	#Both will be available in the current working directory.
	echo "The private and public key pair will be saved to the current directory."
	openssl genrsa -out private.pem 2048
	echo "The private key was created. filename : private.pem"
	openssl rsa -in private.pem -pubout -out public.pem
	echo "The private key was created. filename : public.pem "
	echo "Task complete!"
	sleep 7
	disp
	showMenu
	}

asEnc(){
	#This function is responsible for encrypting directories using the public key. Users must give path to public key and path to directory to be encrypted.
	#This will also create an unique file with the RSAENC suffix and it will also compress it to the max upon encryption.
	if [ -d $2 ];then
		echo "Encrypting directory: $2 using the public key: $1 "
		temp=`echo $(date +%s)`
		tar -cvf ${temp}.tar $2 > /dev/null
		gzip -9 ${temp}.tar
		openssl rsautl -encrypt -pubin -inkey $1 -keyform pem -in ${temp}.tar.gz -out ${temp}RSAENC
		st=$?
		rm -rf ${temp}.tar.gz
		if [ $st -eq 0 ];then
			echo "$2 Encrypted using $1 Encrypted file : ${temp}RSAENC "
		else
			echo "There was some problem. Could not encrypt."
		fi
		sleep 7
		disp
		showMenu
	else
		disp
		echo "Invalid directory path. Please Re-Enter"
		showMenu
	fi

}

asDec(){
	#This function decrypts files that were encrypted using the public key. User should give the encrypted file path and path to the private key file.
	#A unique directory is created as the ourput with RSADEC suffix.
	if [ -f $2 ];then
		echo "Decrypting $2 using private key: $1  "

			temp=`echo $(date +%s)`
			openssl rsautl -decrypt -inkey $1 -keyform pem -in $2 -out ${temp}RSADEC.tar.gz
			st=$?
			gunzip ${temp}RSADEC.tar.gz
			mkdir ${temp}RSADEC
			mv ${temp}RSADEC.tar ./${temp}RSADEC
			cd ${temp}RSADEC
			tar -xvf ${temp}RSADEC.tar > /dev/null
			rm -rf ${temp}RSADEC.tar
			cd ..
			if [ $st -eq 0 ];then 
				echo "Decryption complete! Decrypted directory is : ${temp}RSADEC "
			else
				echo "There was some problem. Could not decrypt."
			fi
			sleep 7
			disp
			showMenu
	else
		disp
		echo "Invalid path to file! Please Re-Enter."
		showMenu

	fi
}

sign(){
	#This function is used to sign data. As inputs this funtion takes, the path to the directory to be signed and the path to the private key.
	#The output is an unique file with RSASIGN suffix.
	if [ -d $2 ];then
		echo "Signing directory: $2 using the private key: $1 "

		temp=`echo $(date +%s)`
		tar -cvf ${temp}.tar $2 > /dev/null
		gzip -9 ${temp}.tar
		openssl rsautl -sign -inkey $1 -keyform pem -in ${temp}.tar.gz -out ${temp}RSASIGN
		st=$?
		rm -rf ${temp}.tar.gz
		if [ $st -eq 0 ];then
			echo "$2 Encrypted using $1 Encrypted file : ${temp}RSASIGN "
		else
			echo "There was some problem. Could not Sign."
		fi
		sleep 7
		disp
		showMenu
	else
		disp
		echo "Invalid directory path. Please Re-Enter."
		showMenu
	fi
}

verify(){
	#This function verifies a sigend file. User must give path to the signed file and the pat to the public key file.
	#Output is an unique directory with RSAUNSIGNED suffix.
	if [ -f $2 ];then
		echo "verifying signed content: $2 using public key: $1 "
		
		temp=`echo $(date +%s)`
		openssl rsautl -verify -pubin -inkey $1 -keyform pem -in $2 -out ${temp}RSAUNSIGNED.tar.gz
		st=$?
		gunzip ${temp}RSAUNSIGNED.tar.gz
		mkdir ${temp}RSAUNSIGNED
		mv ${temp}RSAUNSIGNED.tar ./${temp}RSAUNSIGNED
		cd ${temp}RSAUNSIGNED
		tar -xvf ${temp}RSAUNSIGNED.tar > /dev/null
		rm -rf ${temp}RSAUNSIGNED.tar
		cd ..
		if [ $st -eq 0 ];then 
			echo "Verification complete! Decrypted directory is : ${temp}RSAUNSIGNED "
		else
			echo "There was some problem. Could not verify."
		fi
		sleep 7
		disp
		showMenu

	else
		disp
		echo "Invalid path to file! Please Re-Enter."
		showMenu

	fi
}

genHash(){
	#This function is used for generating hash values. User needs to give hashing Algorithm and path to file
	#Output is the hash value, which the user can save to a file if he/she desires when prompted.
	if [ -f $2 ];then
		echo "Generating $1 hash value for $2 "
		openssl dgst -${1} $2
		echo "Do you want to save this to a file? y/n"
		read ch
		if [ $ch='y' ];then
			touch HashVal.txt
			openssl dgst -${1} $2 > HashVal.txt
			echo "Hash value saved to HashVal.txt in current directory."
		fi
		sleep 5
		disp
		showMenu
	else
		disp
		echo "Invalid path to file! Please Re-Enter."
		showMenu
	fi	
}
disp(){
	#This function is just formatting. It gives bit of look and feel and some useful information.
clear
echo -e "\n======================================================================================================================================================="
echo -e "=======================================================================================================================================================\n"
sh header
echo "======================================================================================================================================================="
echo "Ihsan's Encryptor 		Version 1.0			Author : Mohamed Ihsan Izwer			Blog: www.alphagreytux.wordpress.com"
echo "-------------------------------------------------------------------------------------------------------------------------------------------------------"
echo "Detailed illustration on usage : https://alphagreytux.wordpress.com/2017/04/07/encrypting-and-decrypting-direcotories-using-a-free-tool-developed-by-me"
echo "======================================================================================================================================================="
}
showMenu(){
	#This function is responsible for guiding users in order to get there work done as required.
	#Users enter numbers corresponding to what they need.
	echo "Main Menu"
	echo "++++++++++"
	echo "1. Encrypt a directory."
	echo "2. Decrypt an encrypted directory."
	echo "3. Generate Hash values(to check for integrity violations.)"
	echo "4. Usage and help."
	echo "5. Any other key to exit."
	read c1
		
	case $c1 in 
	'1')
		disp
		echo "Main Menu > Encrypt"
		echo "++++++++++++++++++++++"		
		echo "Choose whether Symmetric or Asymmetric Encyption."
		echo "1. Symmetric"
		echo "2. Asymmetric"
		echo "3. Back"
		read c2
		case $c2 in
		'1')
			disp
			echo "Main Menu > Encrypt > Symmetric"
			echo "+++++++++++++++++++++++++++++++++"
			echo "Choose the symmetric Encyption Algorithm."
			echo "1. Blowfish - cbc"
			echo "2. RC2 - cbc"
			echo "3. RC4"
			echo "4. Data Encryption Standard (DES) - cbc"
			echo "5. Triple DES"
			echo "6. Advanced Encryption Standard (AES) - 128 - cbc"
			echo "7. Advanced Encryption Standard (AES) - 192 - cbc"
			echo "8. Advanced Encryption Standard (AES) - 256 - cbc"
			echo "9. Exit"
			read c3 
			case $c3 in
			'1')
				echo "Enter directory to be encrypted : "
				read c4
				symEnc bf-cbc $c4 
			;;
			'2')
				echo "Enter directory to be encrypted : "
				read c4
				symEnc rc2-cbc $c4
			;;
			'3')
				echo "Enter directory to be encrypted : "
				read c4
				symEnc rc4 $c4
			;;
			'4')
				echo "Enter directory to be encrypted : "
				read c4
				symEnc des-cbc $c4
			;;
			'5')
				echo "Enter directory to be encrypted : "
				read c4
				symEnc des3 $c4
			;;
			'6')
				echo "Enter directory to be encrypted : "
				read c4
				symEnc aes-128-cbc $c4
			;;
			'7')
				echo "Enter directory to be encrypted : "
				read c4
				symEnc aes-192-cbc $c4
			;;
			'8')
				echo "Enter directory to be encrypted : "
				read c4
				symEnc aes-256-cbc $c4
			;;
			'9')
				disp
				showMenu
			;;
			*)
			disp
			echo "Invalid selection! Please Re-Enter"
			showMenu
			;;
			esac
		;;
		'2')
			disp
			echo "Main Menu > Encrypt > Asymmetric"
			echo "+++++++++++++++++++++++++++++++++"
			echo "1. Generate Asymmetric keys."
			echo "2. Encrypt using RSA Public key."
			echo "3. Sign data."
			echo "4. Back."
			read c4
			case $c4 in
				'1')
				disp
				asGen 
				;;
				'2')
				echo "Enter the directory path to encrypt :"
				read c5
				echo "Enter the path to the public key .pem file :"
				read c6
				asEnc $c6 $c5
				;;
				'3')
				echo "Enter the directory path to encrypt :"
				read c5
				echo "Enter the path to the private key .pem file :"
				read c6
				sign $c6 $c5
				;;
				'4')
				disp
				showMenu
				;;
				*)
				disp
				echo "Invalid selection! Please Re-Enter"
				showMenu
				;;
			esac
		;;
		'3')
			disp
			showMenu
		;;
		*)
			disp
			echo "Invalid selection! Please Re-Enter"
			showMenu
		;;
		esac
	;;
	'2')
		disp
		echo "Main Menu > Decrypt"
		echo "++++++++++++++++++++++"
		echo "1. Symmetric."
		echo "2. Asymmetric."
		echo "3. Back."
		read c2
		case $c2 in
		'1')
			disp
			echo "Main Menu > Decrypt > Symmetric"
			echo "+++++++++++++++++++++++++++++++++"
			echo "Choose the symmetric Encyption Algorithm."
			echo "1. Blowfish - cbc"
			echo "2. RC2 - cbc"
			echo "3. RC4"
			echo "4. Data Encryption Standard (DES) - cbc"
			echo "5. Triple DES"
			echo "6. Advanced Encryption Standard (AES) - 128 - cbc"
			echo "7. Advanced Encryption Standard (AES) - 192 - cbc"
			echo "8. Advanced Encryption Standard (AES) - 256 - cbc"
			echo "9. Exit"
			read c3 
			case $c3 in
			'1')
				echo "Enter directory to be decrypted : "
				read c4
				symDec bf-cbc $c4 
			;;
			'2')
				echo "Enter directory to be decrypted : "
				read c4
				symDec rc2-cbc $c4
			;;
			'3')
				echo "Enter directory to be decrypted : "
				read c4
				symDec rc4 $c4
			;;
			'4')
				echo "Enter directory to be decrypted : "
				read c4
				symDec des-cbc $c4
			;;
			'5')
				echo "Enter directory to be decrypted : "
				read c4
				symDec des3 $c4
			;;
			'6')
				echo "Enter directory to be decrypted : "
				read c4
				symDec aes-128-cbc $c4
			;;
			'7')
				echo "Enter directory to be decrypted : "
				read c4
				symDec aes-192-cbc $c4
			;;
			'8')
				echo "Enter directory to be decrypted : "
				read c4
				symDec aes-256-cbc $c4
			;;
			'9')
				disp
				showMenu
			;;
			*)
			disp
			echo "Invalid selection! Please Re-Enter"
			showMenu
			;;
			esac
		;;
		'2')
			disp
			echo "Main Menu > Decrypt > Asymmetric"
			echo "+++++++++++++++++++++++++++++++++"
			echo "1. Decrypt an Encrypted directory."
			echo "2. Decrypt signed data."
			echo "3. Exit"
			read c3 
			case $c3 in
				'1')
				echo "Enter the path to the encrypted directory :"
				read c4
				echo "Enter the path to the private.pem key file :"
				read c5
				asDec $c5 $c4
				;;
				'2')
				echo "Enter the path to the sigend data :"
				read c4
				echo "Enter the path to the public.pem key file :"
				read c5
				verify $c5 $c4
				;;
				'3')
				disp
				showMenu
				;;
				*)
				disp
				echo "Invalid selection! Please Re-Enter."
				showMenu
				;;
			esac
		;;
		'3')
			disp
			showMenu
		;;
		*)
			disp
			echo "Invalid selection! Please Re-Enter"
			showMenu
		;;
		esac
	;;
	'3')
		disp
		echo "Main Menu > Generate Hash"
		echo "++++++++++++++++++++++++++"
		echo "1. MD-5"
		echo "2. SHA"
		echo "3. Exit"
		read c3
		case $c3 in 
			'1')
			echo "Enter path to file :"
			read c4
			genHash md5 $c4
			;;
			'2')
			echo "Enter path to file :"
			read c4
			genHash sha256 $c4
			;;
			'3')
				disp
				showMenu
			;;
			*)
				disp
				echo "Invalid selection! Please Re-Enter"
				showMenu
			;;
		esac
	;;
	'4')
	usageFunc
	showMenu
	;;
	*)
	exit
	;;
	esac
	
}
#This is where the script starts to execute. This script supports command line arguments as well for faster access. So it checks for command line arguments.
#User Inputs are validated and messages are displayed.
disp
if [ $# -eq 0 ];then 
		showMenu
else
	case $1 in
	'enc')
		if [ $# -ne 3 ];then
			echo "Invalid argument(s). Please specify a directory to encrypt."
			usageFunc
			exit
		fi
		case $2 in
		'bf')
			symEnc bf-cbc $3
		;;
		'rc2')
			symEnc rc2-cbc $3
		;;
		'rc4')
			symEnc rc4 $3
		;;
		'des')
			symEnc des-cbc $3
		;;
		'des3')
			symEnc des3 $3
		;;
		'aes-128')
			symEnc aes-128-cbc $3
		;;
		'aes-192')
			symEnc aes-192-cbc $3
		;;
		'aes-256')
			symEnc aes-256-cbc $3
		;;
		*)
		echo "Invalid argument(s). Please refer usage below and retry."
		usageFunc
		exit
		;;
		esac
	;;
	'dec')
		if [ $# -ne 3 ];then
			echo "Invalid argument(s). Please specify a directory to decrypt."
			usageFunc
			exit
		fi
		case $2 in
		'bf')
			symDec bf-cbc $3
		;;
		'rc2')
			symDec rc2-cbc $3
		;;
		'rc4')
			symDec rc4 $3
		;;
		'des')
			symDec des-cbc $3
		;;
		'des3')
			symDec des3 $3
		;;
		'aes-128')
			symDec aes-128-cbc $3
		;;
		'aes-192')
			symDec aes-192-cbc $3
		;;
		'aes-256')
			symDec aes-256-cbc $3
		;;
		*)
		echo "Invalid argument(s). Please refer usage below and retry."
		usageFunc
		exit
		;;
		esac
	;;
	'asgen')
		asGen
	;;
	'asenc')
		if [ $# -ne 3 ];then
			echo "Invalid argument(s). Please specify a directory to encrypt."
			usageFunc
			exit
		fi
		asEnc $2 $3
	;;
	'asdec')
		if [ $# -ne 3 ];then
			echo "Invalid argument(s). Please specify a directory to decrypt."
			usageFunc
			exit
		fi
		asDec $2 $3
	;;
	'sign')
		if [ $# -ne 3 ];then
			echo "Invalid argument(s). Please specify a directory to sign."
			usageFunc
			exit
		fi
		sign $2 $3
	;;
	'ver')
		if [ $# -ne 3 ];then
			echo "Invalid argument(s). Please specify a directory to verify."
			usageFunc
			exit
		fi
		verify $2 $3
	;;
	'hash')
		if [ $# -ne 3 ];then
			echo "Invalid argument(s). Please specify a directory to send to the hash function."
			usageFunc
			exit
		fi
		genHash $2 $3
	;;
	*)
	echo "Invalid argument(s). Please refer usage below and retry."
	usageFunc
	exit
	;;
	esac
fi