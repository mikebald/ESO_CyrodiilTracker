CrownTrackerConstants = CrownTrackerConstants or {}
CrownTrackerConstants.resourceType = {}
CrownTrackerConstants.resourceType.FARM = 1
CrownTrackerConstants.resourceType.MINE = 2
CrownTrackerConstants.resourceType.LUMBER = 3

CrownTrackerConstants.resources = {
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
CrownTrackerConstants.keeps = {
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
}
CrownTrackerConstants.outposts = {
    [132] = "Nikel",
    [133] = "Sejanus",
    [134] = "Bleaker's",
    [163] = "Winter's Peak",
    [164] = "Carmala",
    [165] = "Harlun's"
}
CrownTrackerConstants.towns = {
    [149] = "Vlastarus",
    [151] = "Bruma",
    [152] = "Cropsford"
}
CrownTrackerConstants.scrolltemples = {
    [118] = "Scroll Temple of Altadoon",
    [119] = "Scroll Temple of Mnem",
    [120] = "Scroll Temple of Ghartok",
    [121] = "Scroll Temple of Chim",
    [122] = "Scroll Temple of Ni-Mohk",
    [123] = "Scroll Temple of Alma Ruma"
}

CrownTrackerConstants.destructibles = {
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

CrownTrackerConstants.flipTimes = {}
CrownTrackerConstants.flipTimes.KEEP = 20000
CrownTrackerConstants.flipTimes.OUTPOST = 20000
CrownTrackerConstants.flipTimes.RESOURCE = 20000

CrownTrackerConstants.events.GUILD_CLAIM = 1
CrownTrackerConstants.events.GUILD_LOST = 2
CrownTrackerConstants.events.STATUS_UA = 3
CrownTrackerConstants.events.STATUS_UA_LOST = 4
CrownTrackerConstants.events.KEEP_OWNER_CHANGED = 5
CrownTrackerConstants.events.TICK_DEFENSE = 6
CrownTrackerConstants.events.TICK_OFFENSE = 7
CrownTrackerConstants.events.SCROLL_PICKED_UP = 8
CrownTrackerConstants.events.SCROLL_DROPPED = 9
CrownTrackerConstants.events.SCROLL_RETURNED = 10
CrownTrackerConstants.events.SCROLL_RETURNED_BY_TIMER = 11
CrownTrackerConstants.events.SCROLL_CAPTURED = 12
CrownTrackerConstants.events.EMPEROR_CORONATED = 13
CrownTrackerConstants.events.EMPEROR_DEPOSED = 14
CrownTrackerConstants.events.QUEST_REWARD = 15
CrownTrackerConstants.events.BATTLEGROUND_REWARD = 16
CrownTrackerConstants.events.BATTLEGROUND_MEDAL_REWARD = 16
CrownTrackerConstants.events.DAEDRIC_ARTIFACT_SPAWNED = 17
CrownTrackerConstants.events.DAEDRIC_ARTIFACT_REVEALED = 18
CrownTrackerConstants.events.DAEDRIC_ARTIFACT_DROPPED = 19
CrownTrackerConstants.events.DAEDRIC_ARTIFACT_TAKEN = 20
CrownTrackerConstants.events.DAEDRIC_ARTIFACT_DESPAWNED = 21