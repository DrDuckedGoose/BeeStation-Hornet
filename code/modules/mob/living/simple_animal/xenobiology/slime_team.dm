///Team component for slime_uni
/datum/component/slime_team
    ///who owns this team
    var/mob/living/owner
    ///list of team players, slimes
    var/list/players = list()

/datum/component/slime_team/Initialize(var/mob/living/M)
    if(!M)
        return
    owner = M
    players = list(M)

/datum/component/slime_team/proc/append_player(var/mob/living/simple_animal/slime_uni/S)
    if(istype(S))
        players |= S
        S.position = players.len
        SEND_SIGNAL(src, null, SLIME_TEAM_UPDATE, S) //Send the appended slime to the AI
        return TRUE
    return FALSE
