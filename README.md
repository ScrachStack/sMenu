# sMenu  
A clean, lightweight, and customizable **FiveM** menu system built with **ox_lib** and **oxmysql**, inspired by [vMenu](https://github.com/TomGrobbe/vMenu).  
The goal of **sMenu** is to provide a modular, performance-friendly player menu that can be easily extended and adapted for any server style.

<img width="490" height="619" alt="sMenu preview" src="https://github.com/user-attachments/assets/8374c8ef-93a2-4f74-9293-ba5d9d2e2bae" />

---

## Features
- Optimized UI built with `ox_lib` components  
- Database integration through `oxmysql`  
- Modular structure — easy to expand and customize  
- Future configs: spawn settings, permission system, and category management  
- Open source and community-friendly  

---

## Requirements  
- [oxmysql](https://github.com/overextended/oxmysql)  
- [ox_lib](https://github.com/overextended/ox_lib)

---

## Installation  

1. Run the included `Insert.sql` file in your database.  
2. Verify that both **oxmysql** and **ox_lib** are installed and running.  
3. Add the resource to your `server.cfg`:
   ```cfg
   ensure smenu
Start your server and open the menu in-game.

Configuration files for spawn and permission management will be released soon.

## Credits

- Idea: TomGrobbe/vMenu

- Development: ScrachStack/sMenu

> Licensed under the MIT License
