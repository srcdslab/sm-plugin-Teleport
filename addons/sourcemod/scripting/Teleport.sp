#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <multicolors>

#pragma newdecls required

public Plugin myinfo =
{
	name 		= "Teleport Commands",
	author		= "Obus",
	description	= "Adds commands to teleport clients.",
	version		= "1.3.2",
	url			= "https://github.com/CSSZombieEscape/sm-plugins/blob/master/Teleport/"
}

public void OnPluginStart()
{
	LoadTranslations("common.phrases");

	RegAdminCmd("sm_bring", Command_Bring, ADMFLAG_GENERIC, "Brings a client to your position.");
	RegAdminCmd("sm_goto", Command_Goto, ADMFLAG_GENERIC, "Teleport to a client.");
	RegAdminCmd("sm_send", Command_Send, ADMFLAG_GENERIC, "Send a client to another client.");
	RegAdminCmd("sm_tpaim", Command_TpAim, ADMFLAG_GENERIC, "Teleport a client to your aimpoint.");
}

public Action Command_Bring(int client, int argc)
{
	if (!client)
	{
		ReplyToCommand(client, "[SM] Cannot use command from server console.");
		return Plugin_Handled;
	}

	if (argc < 1)
	{
		CPrintToChat(client, "{green}[SM] {default}Usage: sm_bring <name|#userid>");
		return Plugin_Handled;
	}

	char sArgs[64];
	char sTargetName[MAX_TARGET_LENGTH];
	int iTargets[MAXPLAYERS];
	int iTargetCount;
	bool bIsML;

	GetCmdArg(1, sArgs, sizeof(sArgs));

	if ((iTargetCount = ProcessTargetString(sArgs, client, iTargets, MAXPLAYERS, COMMAND_FILTER_ALIVE, sTargetName, sizeof(sTargetName), bIsML)) <= 0)
	{
		ReplyToTargetError(client, iTargetCount);
		return Plugin_Handled;
	}

	float vecClientPos[3];

	GetClientAbsOrigin(client, vecClientPos);

	for (int i = 0; i < iTargetCount; i++)
	{
		TeleportEntity(iTargets[i], vecClientPos, NULL_VECTOR, NULL_VECTOR);
	}

	CShowActivity2(client, "{green}[SM] {olive}", "{default}Brought {olive}%s{default}.", sTargetName);

	if (iTargetCount > 1)
		LogAction(client, -1, "\"%L\" brought \"%s\"", client, sTargetName);
	else
		LogAction(client, iTargets[0], "\"%L\" brought \"%L\"", client, iTargets[0]);

	return Plugin_Handled;
}

public Action Command_Goto(int client, int argc)
{
	if (!client)
	{
		ReplyToCommand(client, "[SM] Cannot use command from server console.");
		return Plugin_Handled;
	}

	if (argc < 1)
	{
		CPrintToChat(client, "{green}[SM] {default}Usage: sm_goto <name|#userid|@aim>");
		return Plugin_Handled;
	}

	int iTarget;
	char sTarget[32];

	GetCmdArg(1, sTarget, sizeof(sTarget));

	if (strcmp(sTarget, "@aim") == 0)
	{
		if (argc > 1)
		{
			char sOption[2];

			GetCmdArg(2, sOption, sizeof(sOption));

			if (StringToInt(sOption) <= 0)
			{
				float vecAimPoint[3];

				if (!TracePlayerAngles(client, vecAimPoint))
				{
					CPrintToChat(client, "{green}[SM] {default}Couldn't perform trace to your aimpoint.");
					return Plugin_Handled;
				}

				TeleportEntity(client, vecAimPoint, NULL_VECTOR, NULL_VECTOR);

				CShowActivity2(client, "{green}[SM] {olive}", "{default}Teleported to {olive}their aimpoint{default}.");
				LogAction(client, -1, "\"%L\" teleported to their aimpoint", client);

				return Plugin_Handled;
			}
		}

		int iAimTarget = GetClientAimTarget(client, true);

		if (iAimTarget == -1)
		{
			float vecAimPoint[3];

			if (!TracePlayerAngles(client, vecAimPoint))
			{
				CPrintToChat(client, "{green}[SM] {default}Couldn't perform trace to your aimpoint.");
				return Plugin_Handled;
			}

			TeleportEntity(client, vecAimPoint, NULL_VECTOR, NULL_VECTOR);

			CShowActivity2(client, "{green}[SM] {olive}", "{default}Teleported to {olive}their aimpoint{default}.");
			LogAction(client, -1, "\"%L\" teleported to their aimpoint", client);

			return Plugin_Handled;
		}
	}

	if ((iTarget = FindTarget(client, sTarget)) <= 0)
		return Plugin_Handled;

	float vecTargetPos[3];

	GetClientAbsOrigin(iTarget, vecTargetPos);

	TeleportEntity(client, vecTargetPos, NULL_VECTOR, NULL_VECTOR);

	CShowActivity2(client, "{green}[SM] {olive}", "{default}Teleported to {olive}%N{default}.", iTarget);
	LogAction(client, iTarget, "\"%L\" teleported to \"%L\"", client, iTarget);

	return Plugin_Handled;
}

public Action Command_Send(int client, int argc)
{
	if (argc < 2)
	{
		CPrintToChat(client, "{green}[SM] {default}Usage: sm_send <name|#userid> <name|#userid>");
		return Plugin_Handled;
	}

	int iTarget;
	char sArgs[32];
	char sTarget[32];
	char sTargetName[MAX_TARGET_LENGTH];
	int iTargets[MAXPLAYERS];
	int iTargetCount;
	bool bIsML;

	GetCmdArg(1, sArgs, sizeof(sArgs));
	GetCmdArg(2, sTarget, sizeof(sTarget));

	if ((iTargetCount = ProcessTargetString(sArgs, client, iTargets, MAXPLAYERS, COMMAND_FILTER_ALIVE, sTargetName, sizeof(sTargetName), bIsML)) <= 0)
	{
		ReplyToTargetError(client, iTargetCount);
		return Plugin_Handled;
	}

	if (strcmp(sTarget, "@aim") == 0)
	{
		if (!client)
		{
			ReplyToCommand(client, "[SM] Cannot use \"sm_send @aim\" from server console.");
			return Plugin_Handled;
		}

		float vecAimPoint[3];

		if (!TracePlayerAngles(client, vecAimPoint))
		{
			CPrintToChat(client, "{green}[SM] {default}Couldn't perform trace to your aimpoint.");
			return Plugin_Handled;
		}

		for (int i = 0; i < iTargetCount; i++)
		{
			TeleportEntity(iTargets[i], vecAimPoint, NULL_VECTOR, NULL_VECTOR);
		}

		CShowActivity2(client, "{green}[SM] {olive}", "{default}Teleported {olive}%s{default} to {olive}their aimpoint{default}.", sTargetName);

		if (iTargetCount > 1)
			LogAction(client, -1, "\"%L\" teleported target \"%s\" to their aimpoint", client, sTargetName);
		else
			LogAction(client, iTargets[0], "\"%L\" teleported target \"%L\" to their aimpoint", client, iTargets[0]);

		return Plugin_Handled;
	}

	if ((iTarget = FindTarget(client, sTarget)) <= 0)
		return Plugin_Handled;

	float vecTargetPos[3];

	GetClientAbsOrigin(iTarget, vecTargetPos);

	for (int i = 0; i < iTargetCount; i++)
	{
		TeleportEntity(iTargets[i], vecTargetPos, NULL_VECTOR, NULL_VECTOR);
	}

	CShowActivity2(client, "{green}[SM] {olive}", "{default}Teleported {olive}%s{default} to {olive}%N{default}.", sTargetName, iTarget);

	if (iTargetCount > 1)
		LogAction(client, -1, "\"%L\" teleported target \"%s\" to \"%L\"", client, sTargetName, iTarget);
	else
		LogAction(client, iTargets[0], "\"%L\" teleported target \"%L\" to \"%L\"", client, iTargets[0], iTarget);

	return Plugin_Handled;
}

public Action Command_TpAim(int client, int argc)
{
	if (!client)
	{
		ReplyToCommand(client, "[SM] Cannot use command from server console.");
		return Plugin_Handled;
	}

	char sArgs[32];
	char sTargetName[MAX_TARGET_LENGTH];
	int iTargets[MAXPLAYERS];
	int iTargetCount;
	bool bIsML;

	GetCmdArg(1, sArgs, sizeof(sArgs));

	if ((iTargetCount = ProcessTargetString(sArgs, client, iTargets, MAXPLAYERS, COMMAND_FILTER_ALIVE, sTargetName, sizeof(sTargetName), bIsML)) <= 0)
	{
		ReplyToTargetError(client, iTargetCount);
		return Plugin_Handled;
	}

	float vecAimPoint[3];

	TracePlayerAngles(client, vecAimPoint);

	for (int i = 0; i < iTargetCount; i++)
	{
		TeleportEntity(iTargets[i], vecAimPoint, NULL_VECTOR, NULL_VECTOR);
	}

	CShowActivity2(client, "{green}[SM] {olive}", "{default}Teleported {olive}%s{default} to {olive}their aimpoint{default}.", sTargetName);

	if (iTargetCount > 1)
		LogAction(client, -1, "\"%L\" teleported \"%s\" to their aimpoint", client, sTargetName);
	else
		LogAction(client, iTargets[0], "\"%L\" teleported \"%L\" to their aimpoint", client, iTargets[0]);

	return Plugin_Handled;
}

bool TracePlayerAngles(int client, float vecResult[3])
{
	if (!IsClientInGame(client))
		return false;

	float vecEyeAngles[3];
	float vecEyeOrigin[3];

	GetClientEyeAngles(client, vecEyeAngles);
	GetClientEyePosition(client, vecEyeOrigin);

	Handle hTraceRay = TR_TraceRayFilterEx(vecEyeOrigin, vecEyeAngles, MASK_SHOT_HULL, RayType_Infinite, TraceEntityFilter_FilterPlayers);

	if (TR_DidHit(hTraceRay))
	{
		TR_GetEndPosition(vecResult, hTraceRay);

		delete hTraceRay;

		return true;
	}

	delete hTraceRay;

	return false;
}

stock bool TraceEntityFilter_FilterPlayers(int entity, int contentsMask)
{
	return entity > MaxClients;
}
