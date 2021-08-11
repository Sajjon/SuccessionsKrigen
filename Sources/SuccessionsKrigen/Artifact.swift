//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-08-10.
//

import Foundation

public enum Artifact: UInt8, Equatable, CaseIterable {
    case ultimateBook,
         ultimateSword,
    ultimateCloak,
    ultimateWand,
    ultimateShield,
    ultimateStaff,
    ultimateCrown,
    goldenGoose,
    arcaneNecklace,
    casterBracelet,
    mageRing,
    witchesBroach,
    medalValor,
    medalCourage,
    medalHonor,
    medalDistinction,
    fizbinMisfortune,
    thunderMace,
    armoredGauntlets,
    defenderHelm,
    giantFlail,
    ballista,
    stealthShield,
    dragonSword,
    powerAxe,
    divineBreastplate,
    minorScroll,
    majorScroll,
    superiorScroll,
    foremostScroll,
    endlessSackGold,
    endlessBagGold,
    endlessPurseGold,
    nomadBootsMobility,
    travelerBootsMobility,
    rabbitFoot,
    goldenHorseshoe,
    gamblerLuckyCoin,
    fourLeafClover,
    trueCompassMobility,
    sailorsAstrolabeMobility,
    evilEye,
    enchantedHourglass,
    goldWatch,
    skullcap,
    iceCloak,
    fireCloak,
    lightningHelm,
    evercoldIcicle,
    everhotLavaRock,
    lightningRod,
    snakeRing,
    ankh,
    bookElements,
    elementalRing,
    holyPendant,
    pendantFreeWill,
    pendantLife,
    serenityPendant,
    seeingEyePendant,
    kineticPendant,
    pendantDeath,
    wandNegation,
    goldenBow,
    telescope,
    statesmanQuill,
    wizardHat,
    powerRing,
    ammoCart,
    taxLien,
    hideousMask,
    endlessPouchSulfur,
    endlessVialMercury,
    endlessPouchGems,
    endlessCordWood,
    endlessCartOre,
    endlessPouchCrystal,
    spikedHelm,
    spikedShield,
    whitePearl,
    blackPearl,
    magicBook,

    spellScroll = 86,
    armMartyr,
    breastplateAnduran,
    broachShielding,
    battleGarb,
    crystalBall,
    heartFire,
    heartIce,
    helmetAnduran,
    holyHammer,
    legendaryScepter,
    masthead,
    sphereNegation,
    staffWizardry,
    swordBreaker,
    swordAnduran,
    spaceNecromancy

}

public extension Artifact {
    static func randomUltimate() -> Self {
        return .ultimateBook
    }
}
