# Auto Completion

Use Set-PSReadLineKeyHandler to realize auto completion just like BASH in *nix.
All sub-commands are self defined.
We need to implement that PowerShell can show the customized prompts if Tab key is pressed.

**What's the effect**

-   PS> tablet(press tab)

    bootstrap  doctor     freshenv   release

-   PS> tablet b(press tab)

    PS> tablet bootstrap

-   PS> tablet bootstrap(press tab)

    ca     cntlm  init   npm

-   PS> tablet bootstrap c(press tab)

    ca     cntlm

-   PS> tablet bootstrap cn(press tab)

    PS> tablet bootstrap cntlm


**If wanna run automatically**

Copy & Paste to $profile