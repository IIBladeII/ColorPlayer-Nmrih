#include <sourcemod>
#include <sdktools>
#pragma semicolon 1
#pragma newdecls required
#define PLUGIN_VERSION "1.2"

public Plugin myinfo = 
{
    name = "NMRIH Player Color Changer",
    author = "IIBladeII",
    description = "Allows players to change their character color",
    version = PLUGIN_VERSION,
    url = "https://github.com/IIBladeII"
};

// Structure to store color information
enum struct ColorInfo
{
    char name[32];
    int r;
    int g;
    int b;
}

// Array of available colors
ColorInfo g_Colors[] = {
    {"Red", 255, 0, 0},
    {"Green", 0, 255, 0},
    {"Blue", 0, 0, 255},
    {"Yellow", 255, 255, 0},
    {"Cyan", 0, 255, 255},
    {"Magenta", 255, 0, 255},
    {"Orange", 255, 165, 0},
    {"Pink", 255, 192, 203},
    {"Purple", 128, 0, 128},
    {"White", 255, 255, 255},
    {"Black", 0, 0, 0},
    {"Brown", 139, 69, 19},
    {"Gold", 255, 215, 0},
    {"Silver", 192, 192, 192}
};

public void OnPluginStart()
{
    // Register commands
    RegConsoleCmd("sm_color", Command_PlayerColor, "Opens the player color selection menu");
    RegConsoleCmd("sm_colours", Command_PlayerColor, "Opens the player color selection menu (alternative spelling)");
    RegConsoleCmd("sm_colors", Command_PlayerColor, "Opens the player color selection menu (alternative command)");
    
    // Create version ConVar
    CreateConVar("sm_playercolor_version", PLUGIN_VERSION, "Player Color Changer Version", FCVAR_SPONLY|FCVAR_NOTIFY|FCVAR_DONTRECORD);
    
    // Load translations (if you add translation files in the future)
    LoadTranslations("common.phrases");
}

public Action Command_PlayerColor(int client, int args)
{
    if (client == 0)
    {
        ReplyToCommand(client, "[ColorPlayer] This command can only be used in-game.");
        return Plugin_Handled;
    }
    
    if (!IsPlayerAlive(client))
    {
        PrintToChat(client, "[ColorPlayer] You must be alive to use this command!");
        return Plugin_Handled;
    }
    
    ShowColorMenu(client);
    return Plugin_Handled;
}

void ShowColorMenu(int client)
{
    Menu menu = new Menu(ColorMenuHandler);
    menu.SetTitle("Choose a color for your character:");
    
    // Add default color option at the top
    menu.AddItem("default", "Default Color");
    
    // Add all available colors
    for (int i = 0; i < sizeof(g_Colors); i++)
    {
        char info[8];
        IntToString(i, info, sizeof(info));
        menu.AddItem(info, g_Colors[i].name);
    }
    
    menu.ExitButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int ColorMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            char info[8];
            menu.GetItem(param2, info, sizeof(info));
            
            if (StrEqual(info, "default"))
            {
                ResetPlayerColor(param1);
                PrintToChat(param1, "[ColorPlayer] Your color has been reset to default!");
            }
            else
            {
                int colorIndex = StringToInt(info);
                if (colorIndex >= 0 && colorIndex < sizeof(g_Colors))
                {
                    ChangePlayerColor(param1, g_Colors[colorIndex]);
                    PrintToChat(param1, "[ColorPlayer] Your color has been changed to %s!", g_Colors[colorIndex].name);
                }
            }
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
    return 0;
}

void ChangePlayerColor(int client, ColorInfo color)
{
    if (IsValidClient(client))
    {
        SetEntityRenderColor(client, color.r, color.g, color.b, 255);
    }
}

void ResetPlayerColor(int client)
{
    if (IsValidClient(client))
    {
        SetEntityRenderColor(client, 255, 255, 255, 255);
    }
}

bool IsValidClient(int client)
{
    return (client > 0 && client <= MaxClients && IsClientInGame(client) && !IsFakeClient(client));
}