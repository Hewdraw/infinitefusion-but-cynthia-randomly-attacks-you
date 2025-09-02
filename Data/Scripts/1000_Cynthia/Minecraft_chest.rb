def enderChest()
  itemlist = getEnderChestItems()
  raritylist = getEnderChestWeights()
  totalrarities = raritylist.sum
  for item in 1..10
    if item >= 9
      totalrarities -= raritylist[0]
      raritylist[0] = 0
    end
    randomrarity = rand(totalrarities)
    if item <= 5
      randomrarity = 0
    end
    raritylist.each_with_index do |rarity, i|
      if randomrarity < rarity
        randomrarity = i
        break
      else
        randomrarity -= rarity
      end
    end
    randomitem = itemlist[randomrarity][rand(itemlist[randomrarity].length)]
    itemname = (randomitem[1] > 1) ? GameData::Item.get(randomitem[0]).name_plural : GameData::Item.get(randomitem[0]).name
    if $PokemonBag.pbStoreItem(*randomitem)
      pbMessage(_INTL("You got #{randomitem[1]} #{itemname}!"))
    end
  end
end

    
def getEnderChestWeights()
  return [
    70, #common
    80, #rare
    36, #super rare
    16, #secret rare
    1, #ultimate rare
  ]
end

def getEnderChestItems()
  return [
    [
      [:NUGGET, 5],
      [:SLOWPOKETAIL, 5],
      [:RELICGOLD, 5],
      [:RELICSTATUE, 5],
      [:STARPIECE, 5],
      [:COMETSHARD, 5],
      [:HEARTSCALE, 5],
      [:AIRBALLOON, 5],
      [:BRIGHTPOWDER, 1],
      [:ROCKYHELMET, 1],
      [:EJECTBUTTON, 5],
      [:REDCARD, 5],
      [:SHEDSHELL, 1],
      [:SMOKEBALL, 1],
      [:LUCKYEGG, 1],
      [:CLEANSETAG, 1],
      [:GRIPCLAW, 1],
      [:BINDINGBAND, 1],
      [:BIGROOT, 1],
      [:SHELLBELL, 1],
      [:MENTALHERB, 5],
      [:WHITEHERB, 5],
      [:POWERHERB, 5],
      [:MUSCLEBAND, 1],
      [:WISEGLASSES, 1],
      [:RAZORCLAW, 1],
      [:SCOPELENS, 1],
      [:WIDELENS, 1],
      [:ZOOMLENS, 1],
      [:KINGSROCK, 1],
      [:RAZORFANG, 1],
      [:QUICKCLAW, 1],
      [:FOCUSBAND, 1],
      [:FOCUSSASH, 5],
      [:HYPERPOTION, 5],
      [:FULLHEAL, 5],
      [:REVIVE, 1],
      [:RAGECANDYBAR, 5],
      [:HPUP, 5],
      [:PROTEIN, 5],
      [:IRON, 5],
      [:CALCIUM, 5],
      [:ZINC, 5],
      [:CARBOS, 5],
      [:GREATBALL, 5],
      [:PREMIERBALL, 5],
      [:ULTRABALL, 5],
      [:DUSKBALL, 5],
      [:QUICKBALL, 5],
      [:LUMBERRY, 5],
      [:SITRUSBERRY, 5],
      [:MANKEYPAW, 1],
      [:ABILITYCAPSULE, 5],
      [:BERSERKGENE, 5],
      [:BANANA, 5],
      [:SAFETYGOGGLES, 1],
      [:PROTECTIVEPADS, 1],
      [:TERRAINEXTENDER, 1],
      [:ELECTRICSEED, 5],
      [:PSYCHICSEED, 5],
      [:MISTYSEED, 5],
      [:GRASSYSEED, 5],
      [:WEAKNESSPOLICY, 5],
      [:SINNOHCOIN, 2],
      [:GOLDENBOTTLECAP, 5],
      [:ABILITYPATCH, 5],
      [:HEALTHMOCHI, 5],
      [:MUSCLEMOCHI, 5],
      [:RESISTMOCHI, 5],
      [:GENIUSMOCHI, 5],
      [:CLEVERMOCHI, 5],
      [:SWIFTMOCHI, 5],
    ],
    [
      [:BIGNUGGET, 5],
      [:RELICCROWN, 5],
      [:PEARLSTRING, 5],
      [:EVIOLITE, 1],
      [:HEATROCK, 1],
      [:DAMPROCK, 1],
      [:SMOOTHROCK, 1],
      [:ICYROCK, 1],
      [:LIGHTCLAY, 1],
      [:BLACKSLUDGE, 1],
      [:EXPERTBELT, 1],
      [:METRONOME, 1],
      [:FLAMEORB, 1],
      [:TOXICORB, 1],
      [:LIGHTBALL, 1],
      [:THICKCLUB, 1],
      [:STICK, 1],
      [:MAXPOTION, 5],
      [:FULLRESTORE, 5],
      [:MAXREVIVE, 1],
      [:REVIVALHERB, 1],
      [:PPMAX, 1],
      [:CHERISHBALL, 5],
      [:MASTERBALL, 1],
      [:EJECTPACK, 5],
      [:BLUNDERPOLICY, 5],
      [:THROATSPRAY, 5],
      [:FROSTORB, 1],
    ],
    [
      [:CHOICEBAND, 1],
      [:CHOICESPECS, 1],
      [:CHOICESCARF, 1],
      [:LEFTOVERS, 1],
      [:LIFEORB, 1],
      [:ASSAULTVEST, 1],
      [:LOADEDDICE, 1],
      [:HEAVYDUTYBOOTS, 1],
    ],
    [
      [:SACREDASH, 1],
      [:BUNDLEOFBALLOONS, 1],
      [:TOTEMOFUNDYING, 1],
      [:ENDCRYSTAL, 1],
      [:MINECRAFTBALL, 1],
    ],
    [
      [:ULTRANECROZIUMZ, 1],
      [:MAXMUSHROOM, 1],
      [:MEGARING, 1],
    ],
  ]
end