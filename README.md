# QuickAlias.sh
 
Alias in Bash are extremely powerful, yet they are always a hussle to configure if you need to use them 
for just 1 or 2 days. Which can sadly be extremely common, as most small projects / configurations 
require you to visit the same folders and/or run the same lines over and over and over.                 
                                                                                                        
"QuickAlias" is intended to help with that, by adding a few functions to quickly add and delete aliases. 
The idea is to add the calls to your code via "source QuickAlias.sh" or to your bash-code via ".bashrc"
or ".bash_aliases". That way, just using short commands like "ad/ar" you can manipulate aliases 
without going through the troubles of configuring them. 

Example of a .bashrc

    SHELLNAME_4_ALIAS=bash
    . ~/QuickAlias.sh
    start_smart_aliases                                                
                                                                                                        
For questions of what to use, after including *QuickAlias.sh*, just use **"ah"**. ("aliases help")              
