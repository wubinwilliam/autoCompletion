Write-Output "In Test"

# function Get-Replacement {
#     Param(
#         [Parameter(Mandatory=$true)]
#         [array]$cmdArr,
#         [Parameter(Mandatory=$true)]
#         [string]$curCmd
#     )

#     $retArr = [System.Collections.ArrayList]::new()
#     Write-Output $retArr.GetType()

#     foreach ($item in $cmdArr) {
#         if ($item.StartsWith($curCmd)) {
#             $retArr.Add($item)
#         }
#     }

#     return $retArr
# }

#Write-Output (Get-Replacement -cmdArr @("bootstrap","doctor","freshenv","release") -curCmd "bo")

Set-PSReadLineKeyHandler -Key Tab -BriefDescription "CLIprompt" -Description "Tablet CLI command prompt" -ScriptBlock {
    param($key, $arg)

    function Get-Replacement {
        Param(
            [Parameter(Mandatory=$true)]
            [array]$cmdArr,
            [Parameter(Mandatory=$true)]
            [AllowEmptyString()]
            [string]$curCmd
        )
    
        $retArr = @()

        if (($null -ne $curCmd) -and ($curCmd.Length -gt 0)) {
            foreach ($item in $cmdArr) {
                if ($item.StartsWith($curCmd)) {
                    $retArr += $item
                }
            }
        }
        return $retArr
    }

    function Set-DefaultPrompt {
        Param(
            [array] $cmdArr,
            [psobject] $cmdExtent
        )
        [array]$arr = Get-Replacement -cmdArr $cmdArr -curCmd $cmdExtent.Text
        if ($arr.Count -eq 0) {
            #show command prompt
            $cmdArr | Format-Wide {$_} -AutoSize -Force | Out-Host
            [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt($null, [Console]::CursorTop)
        }elseif ($arr.Count -eq 1) {
            #replace the command
            [Microsoft.PowerShell.PSConsoleReadLine]::Replace($cmdExtent.StartOffset, $cmdExtent.EndOffset - $cmdExtent.StartOffset, $arr[0])
        }else {
            #show possible prompts
            $arr | Format-Wide {$_} -AutoSize -Force | Out-Host
            [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt($null, [Console]::CursorTop)
        }
    }

    $ast = $null
    $tokens = $null
    $errors = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)

    $rootCmds = @("bootstrap","doctor","freshenv","release")
    $bootstrapCmds = @("ca","cntlm","init","npm")

    $commandAst = $ast.FindAll({
        $node = $args[0]
        $node -is [System.Management.Automation.Language.CommandAst] -and
            $node.Extent.StartOffset -le $cursor -and
            $node.Extent.EndOffset -ge $cursor
    }, $true) | Select-Object -Last 1

    if ($commandAst -ne $null) {
        $commandName = $commandAst.GetCommandName()
        switch ($commandName) {
            'tablet' { 
                $tabletCmd = $commandAst.CommandElements[1].Extent
                switch ($tabletCmd.Text) {
                    'bootstrap' { 
                        $bootstrapCmd = $commandAst.CommandElements[2].Extent
                        Set-DefaultPrompt -cmdArr $bootstrapCmds -cmdExtent $bootstrapCmd
                        # @("ca","cntlm","init","npm") | Format-Wide {$_} -AutoSize -Force | Out-Host
                        # [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt($null, [Console]::CursorTop)
                     }
                    Default {
                        Set-DefaultPrompt -cmdArr $rootCmds -cmdExtent $tabletCmd
                        # @("bootstrap","doctor","freshenv","release") | Format-Wide {$_} -AutoSize -Force | Out-Host
                        # [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt($null, [Console]::CursorTop)
                    }
                }
             }
            Default {
                [Microsoft.PowerShell.PSConsoleReadLine]::Complete($key, $arg)
            }
        }
    }
}

Set-PSReadLineKeyHandler -Key F1 -Function Complete

# Set-PSReadlineKeyHandler -Key F1 `
#                          -BriefDescription CommandHelp `
#                          -LongDescription "Open the help window for the current command" `
#                          -ScriptBlock {
#     param($key, $arg)

#     $ast = $null
#     $tokens = $null
#     $errors = $null
#     $cursor = $null
#     [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)

#     $commandAst = $ast.FindAll( {
#         $node = $args[0]
#         $node -is [System.Management.Automation.Language.CommandAst] -and
#             $node.Extent.StartOffset -le $cursor -and
#             $node.Extent.EndOffset -ge $cursor
#         }, $true) | Select-Object -Last 1

#     if ($commandAst -ne $null)
#     {
#         $commandName = $commandAst.GetCommandName()
#         if ($commandName -ne $null)
#         {
#             $command = $ExecutionContext.InvokeCommand.GetCommand($commandName, 'All')
#             if ($command -is [System.Management.Automation.AliasInfo])
#             {
#                 $commandName = $command.ResolvedCommandName
#             }

#             if ($commandName -ne $null)
#             {
#                 Get-Help $commandName -ShowWindow
#             }
#         }
#     }
# }

# Set-PSReadlineKeyHandler -Key Alt+j `
#                          -BriefDescription ShowDirectoryMarks `
#                          -LongDescription "Show the currently marked directories" `
#                          -ScriptBlock {
#     param($key, $arg)

#     $testTablet = @{"KEY"="AAAA"}
#     # $testTablet.GetEnumerator() | % {
#     #     [PSCustomObject]@{Key = $_.Key; Dir = $_.Value} } |
#     #     Format-Table -AutoSize | Out-Host
#     [string]"`nFUCK YOU" | Out-Host 

#     [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
# }

# Set-PSReadlineOption -CommandValidationHandler {
#     param([System.Management.Automation.Language.CommandAst]$CommandAst)

#     switch ($CommandAst.GetCommandName())
#     {
#         'git' {
#             $gitCmd = $CommandAst.CommandElements[1].Extent
#             switch ($gitCmd.Text)
#             {
#                 'cmt' {
#                     [Microsoft.PowerShell.PSConsoleReadLine]::Replace(
#                         $gitCmd.StartOffset, $gitCmd.EndOffset - $gitCmd.StartOffset, 'commit')
#                 }
#             }
#         }
#     }
# }