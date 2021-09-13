# hl-yojimbo

## Build and Install
##### Note: Most of the following steps are common on windows, linux and mac. The only difference is in the build & install step.

### 1. Prerequisites:
1.1. Install haxe: (: https://haxe.org/download)  
1.2. Install hashlink: (For linux: http://www.unexpected-vortices.com/haxe/getting-started-hl.html )  
1.3. Install heaps: (For linux: https://heaps.io/documentation/installation.html )  
1.4. Install the modified webidl from git:   
```sh
haxelib git webidl https://github.com/onehundredfeet/webidl.git
```

### 2. Build

2.1. Clone this repo into a clean directory.

Open new terminal in this directory.  
```sh
haxelib dev hl-yojimbo hl-yojimbo
```

This tells haxe to look for the library 'hl-yojimbo' in the directory 'hl-yojimbo'.  The 'dev' keyword tells haxe that the library is local and will be directly referenced instead of being installed to the library cache.

2.2 Clone yojimbo c++ sources in some clean directory
```sh
git clone https://github.com/networkprotocol/yojimbo.git
```
   The content of /src dir will be used in the next step.  
    Note: It is recommended to clone some release tag, or at least make sure that the current cloned commit is stable.  
