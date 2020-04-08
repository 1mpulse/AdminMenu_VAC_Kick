#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <csgo_colors>
#include <adminmenu>

TopMenu g_hAdminMenu = null;

public Plugin myinfo =
{
	name = "[AdminMenu] VAC Kick",
	author = "1mpulse (Discord -> 1mpulse#6496)",
	version = "1.0.0",
	url = "http://plugins.thebestcsgo.ru"
};

public void OnPluginStart()
{
	TopMenu hTopMenu;
	if((hTopMenu = GetAdminTopMenu()) != null) OnAdminMenuReady(hTopMenu);
}

public void OnAdminMenuReady(Handle aTopMenu)
{
	TopMenu hTopMenu = TopMenu.FromHandle(aTopMenu);
	if (hTopMenu == g_hAdminMenu) return;
	g_hAdminMenu = hTopMenu;
	TopMenuObject hMyCategory = g_hAdminMenu.FindCategory("PlayerCommands");
	if(hMyCategory != INVALID_TOPMENUOBJECT)
	{
		g_hAdminMenu.AddItem("sm_vac_kick_item", MenuCallBack1, hMyCategory, "sm_vac_kick_menu", ADMFLAG_ROOT, "Кикнуть игрока (VAC)");
	}
}

public void MenuCallBack1(TopMenu hMenu, TopMenuAction action, TopMenuObject object_id, int iClient, char[] sBuffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption: FormatEx(sBuffer, maxlength, "Кикнуть игрока (VAC)");
		case TopMenuAction_SelectOption: Select_PL_MENU(iClient);
	}
}

stock void Select_PL_MENU(int iClient)
{
	char userid[15], name[64];
	Menu hMenu = new Menu(Select_PL);
	hMenu.SetTitle("Выберите Игрока:");
	hMenu.ExitBackButton = true;
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i))
		{
			IntToString(GetClientUserId(i), userid, sizeof(userid));
			GetClientName(i, name, sizeof(name));
			hMenu.AddItem(userid, name);
		}
	}
	hMenu.Display(iClient, 0);
}

public int Select_PL(Menu hMenu, MenuAction action, int iClient, int iItem)
{
	switch(action)
	{
		case MenuAction_End: delete hMenu;
		case MenuAction_Cancel:
        {
            if(iItem == MenuCancel_ExitBack) g_hAdminMenu.Display(iClient, TopMenuPosition_LastCategory);	
        }
		case MenuAction_Select:
		{
			int u, target;
			char userid[15];
			hMenu.GetItem(iItem, userid, sizeof(userid));
			u = StringToInt(userid);
			target = GetClientOfUserId(u);
			if(target)
			{
				CGOPrintToChatAll("{LIGHTRED}%N был навсегда заблокирован на официальных серверах CS:GO.", target);
				KickClient(target, "#SFUI_DisconnectReason_VAC");
			}
		}
	}
}