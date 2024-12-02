# 🔐 PassWordsmith - Mastering the Art of Password Forging
## Overview
This tool is designed to help you create secure passwords and passphrases effortlessly, featuring a user-friendly interface and advanced options for customization. Whether you're looking for a random password with various character sets or a memorable passphrase from themed word lists, this generator has you covered.

## 🌟 Features

### Random Password Generation
- Customizable password length (1-50 characters)
- Character set selection:
  * Uppercase letters
  * Lowercase letters
  * Numbers
  * Special characters
- Prefix and suffix support for Passwords and Passphrases
- Strength meter with real-time feedback

### Passphrase Generation
- Multiple words lists to choose from:
  * Language lists: English, Spanish
  * Themed lists: 
    - Animals
    - Astronomy
    - Cyberpunk
    - Fantasy
    - Medieval
    - Music
    - Olympian
    - Pirate
    - Sci-Fi
    - Superhero
    - Tech Buzzwords
    - Viking
- Configurable word count (3 as Default)
- Optional separators (numbers/special characters)
- Homoglyph substitution option
- Memorable generation (Mnemonics) using themed lists selected, that can be re-roled
- Prefix and suffix support also included!

*Obligatory xkcd comic related to the software*
*![](https://imgs.xkcd.com/comics/password_strength.png)*

*If the comic didnt convince you, check out this website: <https://www.useapassphrase.com/>

### Database Management
- Optional password saving
- Decoy file generation for security against "curious" individuals
- File visibility toggle (hide/unhide database and decoys)

## 📦 Installation for Users
- **Just download and decompress the release .rar file, then open PassWordsmith_32/64bits.exe to use it**
- *Note: keep the word lists files on the same directory*

### 🛠 Requirements to Run the Script/Source Code
- AutoHotkey v2.0
- Word list files in the same directory:
  * Words_list_english.txt
  * Lista_palabras_espanol.txt
  * Theme-specific wordlist files (e.g., animals-wordlist.txt)

### 📦 How to Run the Script/Source Code
1. Install AutoHotkey v2.0
2. Download the script and word list files
3. Ensure all files are in the same directory
4. Run the script

## 🚀 Usage and GUI Overview

### Random Password Tab
0. Optional: Activate the save passwords to database in settings
1. Set desired password length
2. Select desired character types to include/exclude
3. Optional: Add prefix/suffix
4. Click "Generate"
5. Copy to clipboard (and save to database if setting is activated)

![](https://github.com/CrisDxyz/PassWordsmith/blob/main/img/PassWordsmith%20-%20Random%20Password%20tab.png)

### Passphrase Tab
0. Optional: Activate the save passwords to database in settings
1. Select word lists
2. Optional: Change default word count
3. Add separators (Recommended)
4. Optional: Enable homoglyph substitution
5. Click "Generate"
6. Copy to clipboard (and save to database if setting is activated)

![](https://github.com/CrisDxyz/PassWordsmith/blob/main/img/PassWordsmith%20-%20Random%20Passphrase%20tab.png)

### Settings
- Toggle database saving
- Hide/unhide password and decoy databases
- Generate decoy files for added security

![](https://github.com/CrisDxyz/PassWordsmith/blob/main/img/PassWordsmith%20-%20Settings%20tab%20%2B%20Save%20to%20db%20a%20pass%20with%20substitution.png)

### Checking the Database
0. Be sure to unhide the file first
1. Double click system_logs.txt
2. Scroll down to retrieve any password used in the past

*Note: By the nature of this software there's a chance you forget what each password was used in when time goes by, so*
*you can create a password related to the account using prefix/suffix, like "@SpoonC#m4w?aWejFHvb" for your Forkhub account, using @Spoon and Hvb*
*or directly edit the database to your liking to get a reminder, like "QA!Z$Vb1QQ24uRW - Forkhub.com"*

## Demo Examples

![Coming soon!]("placeholder.link")

![Coming soon!]("placeholder.link")

## 🔒 General Security Best Practices
- Use long passwords (15+ characters)
- Mix character types
- Use different passwords for different accounts
- Keep password database secure
- Use decoy files to protect real database

## 📝 Notes
- Password database is stored in plain text (No encryption for now, maybe later)
- Use with caution for sensitive accounts
- Recommended to encrypt folder containing files
- Using a password manager of some sort is also recommended

## 🆘 Help
- Built-in help accessible via "?" button
- Provides detailed usage and security guidance

## 📄 License
MIT License

## 🌈 Disclaimer
Use at your own risk. Always follow best security practices.
