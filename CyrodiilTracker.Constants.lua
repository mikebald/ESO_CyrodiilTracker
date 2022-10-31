CyroTracker = CyroTracker or {}
CyroTracker.Constants = CyroTracker.Constants or {}

local Constants = CyroTracker.Constants

Constants.keepAlliance = {
    [1] = "AD",
    [2] = "EP",
    [3] = "DC"
}

Constants.keepOutput = {
    [1] = "AD",
    [2] = "EP",
    [3] = "DC",
    [4] = "AD - UA : EP",
    [5] = "AD - UA : DC",
    [6] = "EP - UA : AD",
    [7] = "EP - UA : DC",
    [8] = "DC - UA : AD",
    [9] = "DC - UA : EP"
}

Constants.resourceType = {}
Constants.resourceType.FARM = 1
Constants.resourceType.MINE = 2
Constants.resourceType.LUMBER = 3

Constants.scrolls = {
	[118] =	 136,		-- Elder Scroll of Altadoon
	[119] =	 137,		-- Elder Scroll of Mnem
    [120] =	 138,		-- Elder Scroll of Ghartok
	[121] =	 139,		-- Elder Scroll of Chim
	[122] =	 140,		-- Elder Scroll of Ni-Mohk
    [123] =	 141,		-- Elder Scroll of Alma Ruma
}

Constants.scrolls = {
	[118] =	 "Altadoon",
	[119] =	 "Mnem",
    [120] =	 "Ghartok",
	[121] =	 "Chim",
	[122] =	 "Ni-Mohk",
    [123] =	 "Alma Ruma",
}

Constants.resources = {
    [22] = "Bloodmayne Farm",
    [23] = "Bloodmayne Mine",
    [24] = "Bloodmayne Lumbermill",
    [34] = "Black Boot Lumbermill",
    [35] = "Black Boot Mine",
    [36] = "Black Boot Farm",
    [37] = "Farragut Lumbermill",
    [38] = "Farragut Mine",
    [39] = "Farragut Farm",
    [40] = "Warden Farm",
    [41] = "Warden Lumbermill",
    [42] = "Warden Mine",
    [43] = "Faregyl Farm",
    [44] = "Faregyl Lumbermill",
    [45] = "Faregyl Mine",
    [46] = "Arrius Farm",
    [47] = "Arrius Lumbermill",
    [48] = "Arrius Mine",
    [49] = "Glademist Farm",
    [50] = "Glademist Lumbermill",
    [51] = "Glademist Mine",
    [52] = "Kingscrest Farm",
    [53] = "Kingscrest Lumbermill",
    [54] = "Kingscrest Mine",
    [55] = "Rayles Farm",
    [56] = "Rayles Lumbermill",
    [57] = "Rayles Mine",
    [61] = "Ash Farm",
    [62] = "Ash Lumbermill",
    [63] = "Ash Mine",
    [64] = "Aleswell Mine",
    [65] = "Aleswell Lumbermill",
    [66] = "Aleswell Farm",
    [67] = "Dragonclaw Mine",
    [68] = "Dragonclaw Lumbermill",
    [69] = "Dragonclaw Farm",
    [70] = "Chalman Mine",
    [71] = "Chalman Lumbermill",
    [72] = "Chalman Farm",
    [73] = "Blue Road Mine",
    [74] = "Blue Road Lumbermill",
    [75] = "Blue Road Farm",
    [76] = "Drakelowe Mine",
    [77] = "Drakelowe Lumbermill",
    [78] = "Drakelowe Farm",
    [79] = "Alessia Mine",
    [80] = "Alessia Lumbermill",
    [81] = "Alessia Farm",
    [82] = "Roebeck Mine",
    [83] = "Roebeck Lumbermill",
    [84] = "Roebeck Farm",
    [85] = "Brindle Mine",
    [86] = "Brindle Lumbermill",
    [87] = "Brindle Farm"

}
Constants.tracking = {
    [3] = "Warden",
    [4] = "Rayles",
    [5] = "Glademist",
    [6] = "Ash",
    [7] = "Aleswell",
    [8] = "Dragonclaw",
    [9] = "Chalman",
    [10] = "Arrius",
    [11] = "Kingscrest",
    [12] = "Farragut",
    [13] = "Blue Road",
    [14] = "Drakelowe",
    [15] = "Alessia",
    [16] = "Faregyl",
    [17] = "Roebeck",
    [18] = "Brindle",
    [19] = "Black Boot",
    [20] = "Bloodmayne",
    [132] = "Nikel",
    [133] = "Sejanus",
    [152] = "Cropsford",
    [163] = "Winter's Peak",
    [164] = "Carmala",
    [165] = "Harlun's",
    [134] = "Bleaker's",
    [149] = "Vlastarus",
    [151] = "Bruma"
}
Constants.scrolltemples = {
    [118] = "Scroll Temple of Altadoon",
    [119] = "Scroll Temple of Mnem",
    [120] = "Scroll Temple of Ghartok",
    [121] = "Scroll Temple of Chim",
    [122] = "Scroll Temple of Ni-Mohk",
    [123] = "Scroll Temple of Alma Ruma"
}
Constants.destructibles = {
    [154] = "Alessia Bridge",
    [155] = "Ash Milegate",
    [156] = "Niben River Bridge",
    [157] = "Bay Bridge",
    [158] = "Priory Milegate",
    [159] = "Chorrol Milegate",
    [160] = "Kingscrest Milegate",
    [161] = "Horunn Milegate",
    [162] = "Chalman Milegate"
}

Constants.flipTimes = {}
Constants.flipTimes.KEEP = 20000
Constants.flipTimes.OUTPOST = 20000
Constants.flipTimes.RESOURCE = 20000

Constants.events = {}
Constants.events.GUILD_CLAIM = 1
Constants.events.GUILD_LOST = 2
Constants.events.STATUS_UA = 3
Constants.events.STATUS_UA_LOST = 4
Constants.events.KEEP_OWNER_CHANGED = 5
Constants.events.TICK_DEFENSE = 6
Constants.events.TICK_OFFENSE = 7
Constants.events.SCROLL_PICKED_UP = 8
Constants.events.SCROLL_DROPPED = 9
Constants.events.SCROLL_RETURNED = 10
Constants.events.SCROLL_RETURNED_BY_TIMER = 11
Constants.events.SCROLL_CAPTURED = 12
Constants.events.EMPEROR_CORONATED = 13
Constants.events.EMPEROR_DEPOSED = 14
Constants.events.QUEST_REWARD = 15
Constants.events.BATTLEGROUND_REWARD = 16
Constants.events.BATTLEGROUND_MEDAL_REWARD = 16
Constants.events.DAEDRIC_ARTIFACT_SPAWNED = 17
Constants.events.DAEDRIC_ARTIFACT_REVEALED = 18
Constants.events.DAEDRIC_ARTIFACT_DROPPED = 19
Constants.events.DAEDRIC_ARTIFACT_TAKEN = 20
Constants.events.DAEDRIC_ARTIFACT_DESPAWNED = 21
