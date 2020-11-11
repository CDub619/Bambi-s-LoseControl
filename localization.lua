local _, L = ...
local locale = GetLocale()

if locale == "deDE" then -- translated by Morbis
	L["CC"]          = "CC"
	L["Silence"]     = "Stille"
	L["Interrupt"]   = "Interrupt"
	L["Disarm"]      = "Entwaffnen"
	L["Root"]        = "Wurzeln"
	L["Snare"]       = "Verlangsamung"
	L["Immune"]      = "Immun"
	L["ImmuneSpell"] = "Immun gegen Zauber"
	L["ImmunePhysical"] = "Immune to Physical"
	L["Other"]       = "Andere"
	L["PvE"]         = "PvE"
	L["player"] = "Spieler"
	L["pet"]    = "Haustier"
	L["target"] = "Ziel"
	L["targettarget"] = "TargetTarget"
	L["focus"]  = "Fokus"
	L["focustarget"] = "FocusTarget"
	L["party"]  = "Gruppenmitglied"
	L["party1"] = "Gruppenmitglied 1"
	L["party2"] = "Gruppenmitglied 2"
	L["party3"] = "Gruppenmitglied 3"
	L["party4"] = "Gruppenmitglied 4"
	L["arena"]  = "Arena-Feind"
	L["arena1"] = "Arena-Feind 1"
	L["arena2"] = "Arena-Feind 2"
	L["arena3"] = "Arena-Feind 3"
	L["arena4"] = "Arena-Feind 4"
	L["arena5"] = "Arena-Feind 5"
	L["None"] = "Kein"
	L["Unit Configuration"] = "Einheit-Konfiguration"
	L["Enabled"] = "Aktivieren"
	L["DisableInBG"] = "Deaktivieren Sie in Battlegrounds"
	L["DisableInRaid"] = "Deaktivieren Sie in raid (never in arena)"
	L["DisableInterrupts"] = "Disable Interrupt category for this unit"
	L["ShowNPCInterrupts"] = "Also show Interrupts for NPC units"
	L["DisablePlayerTargetTarget"] = "Disable when unit is Player"
	L["DisableTargetTargetTarget"] = "Disable when unit is Target"
	L["DisablePlayerTargetPlayerTargetTarget"] = "Disabe when unit and Target are Player"
	L["DisableTargetDeadTargetTarget"] = "Disable when Target is a dead unit"
	L["DisableFocusFocusTarget"] = "Disable when unit is Focus"
	L["DisablePlayerFocusPlayerFocusTarget"] = "Disabe when unit and Focus are Player"
	L["DisableFocusDeadFocusTarget"] = "Disable when Focus is a dead unit"
	L["DuplicatePlayerPortrait"] = "Duplicate Icon to show in Portrait"
	L["Anchor"] = "Anker"
	L["CategoriesEnabledLabel"] = "Enabled for the following categories (|cff00ff00[F]|r is friendly unit, |cffff0000[E]|r is enemy unit, |cff134d56[B]|r is helpful aura, \n|cff543f16[D]|r is harmful aura):"
	L["CatFriendly"] = "|cff00ff00[F]|r"
	L["CatEnemy"] = "|cffff0000[E]|r"
	L["CatFriendlyBuff"] = "|cff00ff00[F]|r|cff134d56[B]|r"
	L["CatFriendlyDebuff"] = "|cff00ff00[F]|r|cff543f16[D]|r"
	L["CatEnemyBuff"] = "|cffff0000[E]|r|cff134d56[B]|r"
	L["CatEnemyDebuff"] = "|cffff0000[E]|r|cff543f16[D]|r"
	L["Strata"] = "Strata"
	L["Icon Size"] = "Symbolgröße"
	L["Opacity"] = "Transparenz"
	L["Unlock"] = "Symbole entriegeln"
	L["ReloadUI"] = "ReloadUI"
	L[" (drag an icon to move)"] = " (Ziehen um Symbole zu bewegen)"
	L["Disable OmniCC Support"] = "Deaktiviere OmniCC Unterstützung"
	L["Disable Blizzard Countdown"] = "Disable Blizzard Countdown"
	L["DisableLossOfControlCooldownText"] = "Disable Cooldown on player bars for CC effects"
	L["NeedsReload"] = "Needs ReloadUI to take effect"
	L["Priority"] = "Priorität"
	L["PriorityDescription"] = "Legen Sie die Priorität für jeden Zauberspruch Kategorie aus. Höhere Zahlen haben mehr Priorität. 0 deaktiviert die Kategorie."
	L["LoseControl reset."] = "LoseControl zurücksetzen."
elseif locale == "esES" or locale == "esMX" then -- translated by Babelfish :(
	L["CC"]          = "CC"
	L["Silence"]     = "Silencio"
	L["Interrupt"]   = "Interrupción"
	L["Disarm"]      = "Desarme"
	L["Root"]        = "Inmovilice"
	L["Snare"]       = "Relantización"
	L["Immune"]      = "Inmune"
	L["ImmuneSpell"] = "Inmune a los hechizos"
	L["ImmunePhysical"] = "Inmune a físico"
	L["Other"]       = "Otro"
	L["PvE"]         = "PvE"
	L["player"] = "Jugador"
	L["pet"]    = "Mascotas"
	L["target"] = "Objetivo"
	L["targettarget"] = "Objetivo del Objetivo"
	L["focus"]  = "Foco"
	L["focustarget"] = "Objetivo del Foco"
	L["party"]  = "Partido"
	L["party1"] = "Partido 1"
	L["party2"] = "Partido 2"
	L["party3"] = "Partido 3"
	L["party4"] = "Partido 4"
	L["arena"]  = "Enemigos de la arena"
	L["arena1"] = "Enemigo de la arena 1"
	L["arena2"] = "Enemigo de la arena 2"
	L["arena3"] = "Enemigo de la arena 3"
	L["arena4"] = "Enemigo de la arena 4"
	L["arena5"] = "Enemigo de la arena 5"
	L["None"] = "Ninguno"
	L["Unit Configuration"] = "Configuración de la unidad"
	L["Enabled"] = "Permitido"
	L["DisableInBG"] = "Deshabilitar en los campos de batalla"
	L["DisableInRaid"] = "Deshabilitar en grupo de banda (nunca en arenas)"
	L["DisableInterrupts"] = "Desactivar la categoría de Interrupciones para esta unidad"
	L["ShowNPCInterrupts"] = "Mostrar también Interrupciones para unidades NPC"
	L["DisablePlayerTargetTarget"] = "Deshabilitar cuando la unidad sea el Jugador"
	L["DisableTargetTargetTarget"] = "Deshabilitar cuando la unidad sea el Objetivo"
	L["DisablePlayerTargetPlayerTargetTarget"] = "Deshabilitar cuando la unidad y el Objetivo sean el Jugador"
	L["DisableTargetDeadTargetTarget"] = "Deshabilitar cuando el Objetivo esté muerto"
	L["DisableFocusFocusTarget"] = "Deshabilitar cuando la unidad sea el Foco"
	L["DisablePlayerFocusPlayerFocusTarget"] = "Deshabilitar cuando la unidad y el Foco sean el Jugador"
	L["DisableFocusDeadFocusTarget"] = "Deshabilitar cuando el Foco esté muerto"
	L["DuplicatePlayerPortrait"] = "Duplicar Icono para mostralo en el Portrait"
	L["Anchor"] = "Ancla"
	L["CategoriesEnabledLabel"] = "Activar para las siguientes categorías (|cff00ff00[F]|r es unidad amistosa, |cffff0000[E]|r es unidad enemiga, \n|cff134d56[B]|r es aura beneficiosa, |cff543f16[D]|r es aura perjudicial):"
	L["CatFriendly"] = "|cff00ff00[F]|r"
	L["CatEnemy"] = "|cffff0000[E]|r"
	L["CatFriendlyBuff"] = "|cff00ff00[F]|r|cff134d56[B]|r"
	L["CatFriendlyDebuff"] = "|cff00ff00[F]|r|cff543f16[D]|r"
	L["CatEnemyBuff"] = "|cffff0000[E]|r|cff134d56[B]|r"
	L["CatEnemyDebuff"] = "|cffff0000[E]|r|cff543f16[D]|r"
	L["Strata"] = "Strata"
	L["Icon Size"] = "Tamaño del icono"
	L["Opacity"] = "Opacidad"
	L["Unlock"] = "Desbloquear"
	L["ReloadUI"] = "ReloadUI"
	L[" (drag an icon to move)"] = " (arrastre el icono para moverlo)"
	L["Disable OmniCC Support"] = "Neutralización OmniCC"
	L["Disable Blizzard Countdown"] = "Neutralización Contador de Blizzard"
	L["DisableLossOfControlCooldownText"] = "Deshabilita el Cooldown en las barras del jugador para los efectos de CC"
	L["NeedsReload"] = "ReloadUI necesario para que tenga efecto"
	L["Priority"] = "Prioridad"
	L["PriorityDescription"] = "Establecer la prioridad de cada categoría hechizo a continuación. Los números más altos tienen más prioridad. 0 deshabilita la categoría."
	L["LoseControl reset."] = "LoseControl reajuste."
elseif locale == "frFR" then -- translated by Adirelle
	L["CC"]          = "CC"
	L["Silence"]     = "Silence"
	L["Interrupt"]   = "Interrupt"
	L["Disarm"]      = "Désarmement"
	L["Root"]        = "Immobilisation"
	L["Snare"]       = "Ralentissement"
	L["Immune"]      = "Immunisé"
	L["ImmuneSpell"] = "Immunisé to Spells"
	L["ImmunePhysical"] = "Immune to Physical"
	L["Other"]       = "Autre"
	L["PvE"]         = "PvE"
	L["player"] = "Joueur"
	L["pet"]    = "Animal"
	L["target"] = "Cible"
	L["targettarget"] = "TargetTarget"
	L["focus"]  = "Focalisation"
	L["focustarget"] = "FocusTarget"
	L["party"]  = "Membre du groupe"
	L["party1"] = "Membre du groupe n°1"
	L["party2"] = "Membre du groupe n°2"
	L["party3"] = "Membre du groupe n°3"
	L["party4"] = "Membre du groupe n°4"
	L["arena"]  = "Ennemi d'arène"
	L["arena1"] = "Ennemi d'arène n°1"
	L["arena2"] = "Ennemi d'arène n°2"
	L["arena3"] = "Ennemi d'arène n°3"
	L["arena4"] = "Ennemi d'arène n°4"
	L["arena5"] = "Ennemi d'arène n°5"
	L["None"] = "Aucun"
	L["Unit Configuration"] = "Configuration d'unité"
	L["Enabled"] = "Activé"
	L["DisableInBG"] = "Désactiver en champ de bataille"
	L["DisableInRaid"] = "Désactiver en raid (never in arena)"
	L["DisableInterrupts"] = "Disable Interrupt category for this unit"
	L["ShowNPCInterrupts"] = "Also show Interrupts for NPC units"
	L["DisablePlayerTargetTarget"] = "Disable when unit is Player"
	L["DisableTargetTargetTarget"] = "Disable when unit is Target"
	L["DisablePlayerTargetPlayerTargetTarget"] = "Disabe when unit and Target are Player"
	L["DisableTargetDeadTargetTarget"] = "Disable when Target is a dead unit"
	L["DisableFocusFocusTarget"] = "Disable when unit is Focus"
	L["DisablePlayerFocusPlayerFocusTarget"] = "Disabe when unit and Focus are Player"
	L["DisableFocusDeadFocusTarget"] = "Disable when Focus is a dead unit"
	L["DuplicatePlayerPortrait"] = "Duplicate Icon to show in Portrait"
	L["Anchor"] = "Ancre"
	L["CategoriesEnabledLabel"] = "Enabled for the following categories (|cff00ff00[F]|r is friendly unit, |cffff0000[E]|r is enemy unit, |cff134d56[B]|r is helpful aura, \n|cff543f16[D]|r is harmful aura):"
	L["CatFriendly"] = "|cff00ff00[F]|r"
	L["CatEnemy"] = "|cffff0000[E]|r"
	L["CatFriendlyBuff"] = "|cff00ff00[F]|r|cff134d56[B]|r"
	L["CatFriendlyDebuff"] = "|cff00ff00[F]|r|cff543f16[D]|r"
	L["CatEnemyBuff"] = "|cffff0000[E]|r|cff134d56[B]|r"
	L["CatEnemyDebuff"] = "|cffff0000[E]|r|cff543f16[D]|r"
	L["Strata"] = "Strata"
	L["Icon Size"] = "Taille d'icône"
	L["Opacity"] = "Opacité"
	L["Unlock"] = "Déverrouiller"
	L["ReloadUI"] = "ReloadUI"
	L[" (drag an icon to move)"] = " (déplacez un icône par glisser/traînez l'icône pour le)"
	L["Disable OmniCC Support"] = "Désactiver OmniCC"
	L["Disable Blizzard Countdown"] = "Disable Blizzard Countdown"
	L["DisableLossOfControlCooldownText"] = "Disable Cooldown on player bars for CC effects"
	L["NeedsReload"] = "Needs ReloadUI to take effect"
	L["Priority"] = "Priorité"
	L["PriorityDescription"] = "Définissez la priorité de chaque catégorie sort ci-dessous. Un nombre plus élevé ont une plus grande priorité. 0 désactive la catégorie."
	L["LoseControl reset."] = "Remettre à zéro."
elseif locale == "koKR" then -- translated by zuximus
	L["CC"]          = "군중제어"
	L["Silence"]     = "침묵"
	L["Interrupt"]   = "Interrupt"
	L["Disarm"]      = "무장 해제"
	L["Root"]        = "뿌리묶기"
	L["Snare"]       = "덫"
	L["Immune"]      = "면역성이 있는"
	L["ImmuneSpell"] = "면역성이 있는 to Spells"
	L["ImmunePhysical"] = "Immune to Physical"
	L["Other"]       = "다른"
	L["PvE"]         = "PvE"
	L["player"] = "플레이어"
	L["pet"]    = "애완 동물"
	L["target"] = "대상"
	L["targettarget"] = "TargetTarget"
	L["focus"]  = "주시대상"
	L["focustarget"] = "FocusTarget"
	L["party"]  = "파티원"
	L["party1"] = "파티원 1"
	L["party2"] = "파티원 2"
	L["party3"] = "파티원 3"
	L["party4"] = "파티원 4"
	L["arena"]  = "투기장"
	L["arena1"] = "투기장 1"
	L["arena2"] = "투기장 2"
	L["arena3"] = "투기장 3"
	L["arena4"] = "투기장 4"
	L["arena5"] = "투기장 5"
	L["None"] = "없음"
	L["Unit Configuration"] = "유닛 설정"
	L["Enabled"] = "활성화"
	L["DisableInBG"] = "전장에서 사용 안함"
	L["DisableInRaid"] = "Disable in raid group (never in arena)"
	L["DisableInterrupts"] = "Disable Interrupt category for this unit"
	L["ShowNPCInterrupts"] = "Also show Interrupts for NPC units"
	L["DisablePlayerTargetTarget"] = "Disable when unit is Player"
	L["DisableTargetTargetTarget"] = "Disable when unit is Target"
	L["DisablePlayerTargetPlayerTargetTarget"] = "Disabe when unit and Target are Player"
	L["DisableTargetDeadTargetTarget"] = "Disable when Target is a dead unit"
	L["DisableFocusFocusTarget"] = "Disable when unit is Focus"
	L["DisablePlayerFocusPlayerFocusTarget"] = "Disabe when unit and Focus are Player"
	L["DisableFocusDeadFocusTarget"] = "Disable when Focus is a dead unit"
	L["DuplicatePlayerPortrait"] = "Duplicate Icon to show in Portrait"
	L["Anchor"] = "기준"
	L["CategoriesEnabledLabel"] = "Enabled for the following categories (|cff00ff00[F]|r is friendly unit, |cffff0000[E]|r is enemy unit, |cff134d56[B]|r is helpful aura, \n|cff543f16[D]|r is harmful aura):"
	L["CatFriendly"] = "|cff00ff00[F]|r"
	L["CatEnemy"] = "|cffff0000[E]|r"
	L["CatFriendlyBuff"] = "|cff00ff00[F]|r|cff134d56[B]|r"
	L["CatFriendlyDebuff"] = "|cff00ff00[F]|r|cff543f16[D]|r"
	L["CatEnemyBuff"] = "|cffff0000[E]|r|cff134d56[B]|r"
	L["CatEnemyDebuff"] = "|cffff0000[E]|r|cff543f16[D]|r"
	L["Strata"] = "프레임 우선순위"
	L["Icon Size"] = "아이콘 크기"
	L["Opacity"] = "불투명도"
	L["Unlock"] = "잠금 해제"
	L["ReloadUI"] = "ReloadUI"
	L[" (drag an icon to move)"] = " (마우스로 아이콘을 끌면 이동함)"
	L["Disable OmniCC Support"] = "OmniCC 비활성"
	L["Disable Blizzard Countdown"] = "Disable Blizzard Countdown"
	L["DisableLossOfControlCooldownText"] = "Disable Cooldown on player bars for CC effects"
	L["NeedsReload"] = "Needs ReloadUI to take effect"
	L["Priority"] = "앞서 기"
	L["PriorityDescription"] = "아래의 각 맞춤법 카테고리의 우선 순위를 설정합니다. 높은 숫자가 더 우선 순위가 있습니다. 0 범주를 사용할 수 없습니다."
	L["LoseControl reset."] = "LoseControl 초기화."
elseif locale == "ptBR" then -- translated by Google translate :(
	L["CC"]          = "CC"
	L["Silence"]     = "Silêncio"
	L["Interrupt"]   = "Interrupt"
	L["Disarm"]      = "Desarmar"
	L["Root"]        = "Imobilizar"
	L["Snare"]       = "Laço"
	L["Immune"]      = "Imune"
	L["ImmuneSpell"] = "Imune a magias"
	L["ImmunePhysical"] = "Immune to Physical"
	L["Other"]       = "Outro"
	L["PvE"]         = "PvE"
	L["player"] = "Jogador"
	L["pet"]    = "Animal de estimação"
	L["target"] = "Alvo"
	L["targettarget"] = "TargetTarget"
	L["focus"]  = "Foco"
	L["focustarget"] = "FocusTarget"
	L["party"]  = "Partido"
	L["party1"] = "Partido 1"
	L["party2"] = "Partido 2"
	L["party3"] = "Partido 3"
	L["party4"] = "Partido 4"
	L["arena"]  = "Arena"
	L["arena1"] = "Arena 1"
	L["arena2"] = "Arena 2"
	L["arena3"] = "Arena 3"
	L["arena4"] = "Arena 4"
	L["arena5"] = "Arena 5"
	L["None"] = "Nenhum"
	L["Unit Configuration"] = "Configuração da unidade"
	L["Enabled"] = "Habilitado"
	L["DisableInBG"] = "Desativar em Battlegrounds"
	L["DisableInRaid"] = "Desativar em raid (never in arena)"
	L["DisableInterrupts"] = "Disable Interrupt category for this unit"
	L["ShowNPCInterrupts"] = "Also show Interrupts for NPC units"
	L["DisablePlayerTargetTarget"] = "Disable when unit is Player"
	L["DisableTargetTargetTarget"] = "Disable when unit is Target"
	L["DisablePlayerTargetPlayerTargetTarget"] = "Disabe when unit and Target are Player"
	L["DisableTargetDeadTargetTarget"] = "Disable when Target is a dead unit"
	L["DisableFocusFocusTarget"] = "Disable when unit is Focus"
	L["DisablePlayerFocusPlayerFocusTarget"] = "Disabe when unit and Focus are Player"
	L["DisableFocusDeadFocusTarget"] = "Disable when Focus is a dead unit"
	L["DuplicatePlayerPortrait"] = "Duplicate Icon to show in Portrait"
	L["Anchor"] = "Âncora"
	L["CategoriesEnabledLabel"] = "Enabled for the following categories (|cff00ff00[F]|r is friendly unit, |cffff0000[E]|r is enemy unit, |cff134d56[B]|r is helpful aura, \n|cff543f16[D]|r is harmful aura):"
	L["CatFriendly"] = "|cff00ff00[F]|r"
	L["CatEnemy"] = "|cffff0000[E]|r"
	L["CatFriendlyBuff"] = "|cff00ff00[F]|r|cff134d56[B]|r"
	L["CatFriendlyDebuff"] = "|cff00ff00[F]|r|cff543f16[D]|r"
	L["CatEnemyBuff"] = "|cffff0000[E]|r|cff134d56[B]|r"
	L["CatEnemyDebuff"] = "|cffff0000[E]|r|cff543f16[D]|r"
	L["Strata"] = "Strata"
	L["Icon Size"] = "Tamanho do ícone"
	L["Opacity"] = "Opacidade"
	L["Unlock"] = "Destravar"
	L["ReloadUI"] = "ReloadUI"
	L[" (drag an icon to move)"] = " (arrastar um ícone para mover)"
	L["Disable OmniCC Support"] = "Desativar OmniCC Suporte"
	L["Disable Blizzard Countdown"] = "Disable Blizzard Countdown"
	L["DisableLossOfControlCooldownText"] = "Disable Cooldown on player bars for CC effects"
	L["NeedsReload"] = "Needs ReloadUI to take effect"
	L["Priority"] = "Prioridade"
	L["PriorityDescription"] = "Definir a prioridade de cada categoria feitiço abaixo. Os números mais altos têm mais prioridade. 0 desativa a categoria."
	L["LoseControl reset."] = "LoseControl redefinir."
elseif locale == "ruRU" then -- translated by Termoshpuntik
	L["CC"]          = "Потеря контроля"
	L["Silence"]     = "Антимагия"
	L["Interrupt"]   = "Interrupt"
	L["Disarm"]      = "Разоружение"
	L["Root"]        = "Удержание на месте"
	L["Snare"]       = "Замедление"
	L["Immune"]      = "Иммуно"
	L["ImmuneSpell"] = "Иммуно to Spells"
	L["ImmunePhysical"] = "Immune to Physical"
	L["Other"]       = "другой"
	L["PvE"]         = "PvE"
	L["player"] = "Игрок"
	L["pet"]    = "домашнее животное"
	L["target"] = "Цель"
	L["targettarget"] = "TargetTarget"
	L["focus"]  = "Фокус"
	L["focustarget"] = "FocusTarget"
	L["party"]  = "член группы"
	L["party1"] = "1-й член группы"
	L["party2"] = "2-й член группы"
	L["party3"] = "3-й член группы"
	L["party4"] = "4-й член группы"
	L["arena"]  = "Противник арены"
	L["arena1"] = "Противник арены 1"
	L["arena2"] = "Противник арены 2"
	L["arena3"] = "Противник арены 3"
	L["arena4"] = "Противник арены 4"
	L["arena5"] = "Противник арены 5"
	L["None"] = "Никакие"
	L["Unit Configuration"] = "Конфигурация блока"
	L["Enabled"] = "Включить"
	L["DisableInBG"] = "Отключить в поле боя"
	L["DisableInRaid"] = "Отключить в набег (never in arena)"
	L["DisableInterrupts"] = "Disable Interrupt category for this unit"
	L["ShowNPCInterrupts"] = "Also show Interrupts for NPC units"
	L["DisablePlayerTargetTarget"] = "Disable when unit is Player"
	L["DisableTargetTargetTarget"] = "Disable when unit is Target"
	L["DisablePlayerTargetPlayerTargetTarget"] = "Disabe when unit and Target are Player"
	L["DisableTargetDeadTargetTarget"] = "Disable when Target is a dead unit"
	L["DisableFocusFocusTarget"] = "Disable when unit is Focus"
	L["DisablePlayerFocusPlayerFocusTarget"] = "Disabe when unit and Focus are Player"
	L["DisableFocusDeadFocusTarget"] = "Disable when Focus is a dead unit"
	L["DuplicatePlayerPortrait"] = "Duplicate Icon to show in Portrait"
	L["Anchor"] = "Анкер"
	L["CategoriesEnabledLabel"] = "Enabled for the following categories (|cff00ff00[F]|r is friendly unit, |cffff0000[E]|r is enemy unit, |cff134d56[B]|r is helpful aura, \n|cff543f16[D]|r is harmful aura):"
	L["CatFriendly"] = "|cff00ff00[F]|r"
	L["CatEnemy"] = "|cffff0000[E]|r"
	L["CatFriendlyBuff"] = "|cff00ff00[F]|r|cff134d56[B]|r"
	L["CatFriendlyDebuff"] = "|cff00ff00[F]|r|cff543f16[D]|r"
	L["CatEnemyBuff"] = "|cffff0000[E]|r|cff134d56[B]|r"
	L["CatEnemyDebuff"] = "|cffff0000[E]|r|cff543f16[D]|r"
	L["Strata"] = "Strata"
	L["Icon Size"] = "Размер значка"
	L["Opacity"] = "Прозрачность"
	L["Unlock"] = "Разблокировать"
	L["ReloadUI"] = "ReloadUI"
	L[" (drag an icon to move)"] = " (перемещайте значок с помошью курсора мыши)"
	L["Disable OmniCC Support"] = "Отключить OmniCC"
	L["Disable Blizzard Countdown"] = "Disable Blizzard Countdown"
	L["DisableLossOfControlCooldownText"] = "Disable Cooldown on player bars for CC effects"
	L["NeedsReload"] = "Needs ReloadUI to take effect"
	L["Priority"] = "приоритет"
	L["PriorityDescription"] = "Установить приоритет для каждого заклинания категории ниже. Более высокие значения имеют больший приоритет. 0 отключает эту категорию."
	L["LoseControl reset."] = "Сброс настроек LoseControl."
elseif locale == "zhCN" then -- translated by 狂飙
	L["CC"]          = "控制类技能"
	L["Silence"]     = "沉默类技能"
	L["Interrupt"]   = "Interrupt"
	L["Disarm"]      = "缴械类技能"
	L["Root"]        = "定身类技能"
	L["Snare"]       = "减速类技能"
	L["Immune"]      = "免疫"
	L["ImmuneSpell"] = "法术免疫"
	L["ImmunePhysical"] = "Immune to Physical"
	L["Other"]       = "其他"
	L["PvE"]         = "PvE"
	L["player"] = "玩家"
	L["pet"]    = "宠物"
	L["target"] = "目标"
	L["targettarget"] = "TargetTarget"
	L["focus"]  = "焦点"
	L["focustarget"] = "FocusTarget"
	L["party"]  = "队友"
	L["party1"] = "队友1"
	L["party2"] = "队友2"
	L["party3"] = "队友3"
	L["party4"] = "队友4"
	L["arena"]  = "竞技场敌人"
	L["arena1"] = "竞技场敌人1"
	L["arena2"] = "竞技场敌人2"
	L["arena3"] = "竞技场敌人3"
	L["arena4"] = "竞技场敌人4"
	L["arena5"] = "竞技场敌人5"
	L["None"] = "无"
	L["Unit Configuration"] = "单位配置"
	L["Enabled"] = "启用"
	L["DisableInBG"] = "禁止在戰場"
	L["DisableInRaid"] = "Disable in raid group (never in arena)"
	L["DisableInterrupts"] = "Disable Interrupt category for this unit"
	L["ShowNPCInterrupts"] = "Also show Interrupts for NPC units"
	L["DisablePlayerTargetTarget"] = "Disable when unit is Player"
	L["DisableTargetTargetTarget"] = "Disable when unit is Target"
	L["DisablePlayerTargetPlayerTargetTarget"] = "Disabe when unit and Target are Player"
	L["DisableTargetDeadTargetTarget"] = "Disable when Target is a dead unit"
	L["DisableFocusFocusTarget"] = "Disable when unit is Focus"
	L["DisablePlayerFocusPlayerFocusTarget"] = "Disabe when unit and Focus are Player"
	L["DisableFocusDeadFocusTarget"] = "Disable when Focus is a dead unit"
	L["DuplicatePlayerPortrait"] = "Duplicate Icon to show in Portrait"
	L["Anchor"] = "锚点"
	L["CategoriesEnabledLabel"] = "Enabled for the following categories (|cff00ff00[F]|r is friendly unit, |cffff0000[E]|r is enemy unit, |cff134d56[B]|r is helpful aura, \n|cff543f16[D]|r is harmful aura):"
	L["CatFriendly"] = "|cff00ff00[F]|r"
	L["CatEnemy"] = "|cffff0000[E]|r"
	L["CatFriendlyBuff"] = "|cff00ff00[F]|r|cff134d56[B]|r"
	L["CatFriendlyDebuff"] = "|cff00ff00[F]|r|cff543f16[D]|r"
	L["CatEnemyBuff"] = "|cffff0000[E]|r|cff134d56[B]|r"
	L["CatEnemyDebuff"] = "|cffff0000[E]|r|cff543f16[D]|r"
	L["Strata"] = "层级"
	L["Icon Size"] = "大小"
	L["Opacity"] = "透明度"
	L["Unlock"] = "解锁"
	L["ReloadUI"] = "ReloadUI"
	L[" (drag an icon to move)"] = "（拖动图标移动）"
	L["Disable OmniCC Support"] = "禁用 OmniCC 支持"
	L["Disable Blizzard Countdown"] = "Disable Blizzard Countdown"
	L["DisableLossOfControlCooldownText"] = "Disable Cooldown on player bars for CC effects"
	L["NeedsReload"] = "Needs ReloadUI to take effect"
	L["Priority"] = "优先"
	L["PriorityDescription"] = "设置优先级为每个法术类。数字越大，有更高的优先级。 0禁用之类的。"
	L["LoseControl reset."] = "LoseControl 已重置"
elseif locale == "zhTW" then -- translated by 狂飙
	L["CC"]          = "控制類技能"
	L["Silence"]     = "沉默類技能"
	L["Interrupt"]   = "Interrupt"
	L["Disarm"]      = "繳械類技能"
	L["Root"]        = "定身類技能"
	L["Snare"]       = "減速類技能"
	L["Immune"]      = "免疫"
	L["ImmuneSpell"] = "法術免疫"
	L["ImmunePhysical"] = "Immune to Physical"
	L["Other"]       = "其他"
	L["PvE"]         = "PvE"
	L["player"] = "玩家"
	L["pet"]    = "寵物"
	L["target"] = "目標"
	L["targettarget"] = "TargetTarget"
	L["focus"]  = "焦點"
	L["focustarget"] = "FocusTarget"
	L["party"]  = "隊友"
	L["party1"] = "隊友1"
	L["party2"] = "隊友2"
	L["party3"] = "隊友3"
	L["party4"] = "隊友4"
	L["arena"]  = "競技場敵人"
	L["arena1"] = "競技場敵人1"
	L["arena2"] = "競技場敵人2"
	L["arena3"] = "競技場敵人3"
	L["arena4"] = "競技場敵人4"
	L["arena5"] = "競技場敵人5"
	L["None"] = "無"
	L["Unit Configuration"] = "單位配置"
	L["Enabled"] = "啟用"
	L["DisableInBG"] = "禁止在战场"
	L["DisableInRaid"] = "Disable in raid group (never in arena)"
	L["DisableInterrupts"] = "Disable Interrupt category for this unit"
	L["ShowNPCInterrupts"] = "Also show Interrupts for NPC units"
	L["DisablePlayerTargetTarget"] = "Disable when unit is Player"
	L["DisableTargetTargetTarget"] = "Disable when unit is Target"
	L["DisablePlayerTargetPlayerTargetTarget"] = "Disabe when unit and Target are Player"
	L["DisableTargetDeadTargetTarget"] = "Disable when Target is a dead unit"
	L["DisableFocusFocusTarget"] = "Disable when unit is Focus"
	L["DisablePlayerFocusPlayerFocusTarget"] = "Disabe when unit and Focus are Player"
	L["DisableFocusDeadFocusTarget"] = "Disable when Focus is a dead unit"
	L["DuplicatePlayerPortrait"] = "Duplicate Icon to show in Portrait"
	L["Anchor"] = "錨點"
	L["CategoriesEnabledLabel"] = "Enabled for the following categories (|cff00ff00[F]|r is friendly unit, |cffff0000[E]|r is enemy unit, |cff134d56[B]|r is helpful aura, \n|cff543f16[D]|r is harmful aura):"
	L["CatFriendly"] = "|cff00ff00[F]|r"
	L["CatEnemy"] = "|cffff0000[E]|r"
	L["CatFriendlyBuff"] = "|cff00ff00[F]|r|cff134d56[B]|r"
	L["CatFriendlyDebuff"] = "|cff00ff00[F]|r|cff543f16[D]|r"
	L["CatEnemyBuff"] = "|cffff0000[E]|r|cff134d56[B]|r"
	L["CatEnemyDebuff"] = "|cffff0000[E]|r|cff543f16[D]|r"
	L["Strata"] = "層級"
	L["Icon Size"] = "大小"
	L["Opacity"] = "透明度"
	L["Unlock"] = "解鎖"
	L["ReloadUI"] = "ReloadUI"
	L[" (drag an icon to move)"] = "（拖動圖示移動）"
	L["Disable OmniCC Support"] = "禁用 OmniCC 支持"
	L["Disable Blizzard Countdown"] = "Disable Blizzard Countdown"
	L["DisableLossOfControlCooldownText"] = "Disable Cooldown on player bars for CC effects"
	L["NeedsReload"] = "Needs ReloadUI to take effect"
	L["Priority"] = "優先"
	L["PriorityDescription"] = "設置優先級為每個法術類。數字越大，有更高的優先級。 0禁用之類的。"
	L["LoseControl reset."] = "LoseControl 已重置"
else -- default English
	L["CC"]          = "CC"
	L["Silence"]     = "Silence"
	L["RootPhyiscal_Special"] = "Roots: Phyiscal"
	L["RootMagic_Special"] = "Roots: Magic"
	L["Root"]        = "Roots"
	L["ImmunePlayer"]      = "Immune: Player"
	L["Disarm_Warning"]      = "Disarm: Warning"
	L["CC_Warning"]      = "CC: Warning"
	L["Enemy_Smoke_Bomb"]      = "Enemy Smoke Bomb"
	L["Stealth"] = "Stealths"
	L["Immune"]      = "Immune"
	L["ImmuneSpell"] = "Immune: Spells"
	L["ImmunePhysical"] = "Immune: Physical"
	L["AuraMastery_Cast_Auras"] = "Aura Masterys"
	L["ROP_Vortex"] = "AOE: Unique Snares"
	L["Disarm"]      = "Disarms"
	L["Haste_Reduction"]      = "Cast Time Slows"
	L["Dmg_Hit_Reduction"]      = "Hit Reduction"
	L["Interrupt"]   = "Interrupt"
	L["AOE_DMG_Modifiers"]   = "Dmg Amplifiers"
	L["Friendly_Smoke_Bomb"] = "Smoke Bomb"
	L["AOE_Spell_Refections"]   = "AOE Spell Refections"
	L["Trees"]   = "Spells w/o Auras"
	L["Speed_Freedoms"]   = "Freedoms & Speed"
	L["Freedoms"]   = "Freedoms"
	L["Friendly_Defensives"]   = "Defensives"
	L["Mana_Regen"]   = "Mana Regen"
	L["CC_Reduction"]   = "CC: Reduction"
	L["Personal_Offensives"]   = "Offensives: Personal"
	L["Peronsal_Defensives"]   = "Defensives: Personal"
	L["Movable_Cast_Auras"]   = "Cast: Moving"

	L["Other"]       = "Other"
	L["PvE"]         = "PvE"

	L["SnareSpecial"]       = "Snare: Special"
	L["SnarePhysical70"]       = "Snare 70%: Physical"
	L["SnareMagic70"]       = "Snare 70%: Magic"
	L["SnarePhysical50"]       = "Snare 50% :Physical"
	L["SnarePosion50"]       = "Snare 50%: Posion"
	L["SnareMagic50"]       = "Snare 50%: Magic"
	L["SnarePhysical30"]       = "Snare 30%: Physical"
	L["SnareMagic30"]       = "Snare 30%: Magic"
	L["Snare"]       = "Snare"


	L["Drink_Purge"] = "Drink"
	L["Immune_Arena"] = "Immune"
	L["CC_Arena"] = "CC"
	L["Silence_Arena"] = "Silence"
	L["Special_High"] = "High Priority"
	L["Ranged_Major_OffenisiveCDs"] = "Ranged Offenisives"
	L["Roots_90_Snares"] = "Roots"
	L["Disarms"] = "Disarms"
	L["Melee_Major_OffenisiveCDs"] = "Melee Offenisives"
	L["Big_Defensive_CDs"] = "Defensive CDs"
	L["Player_Party_OffensiveCDs"] = "Party Offensives"
	L["Small_Offenisive_CDs"] = "Minor Offenisives"
	L["Small_Defensive_CDs"] = "Minor Defensives"
	L["Freedoms_Speed"] = "Freedoms / Speed"
	L["Snares_WithCDs"] = "Snares: Major"
	L["Special_Low"] = "Low Priority"
	L["Snares_Ranged_Spamable"] = "Snares: Ranged"
	L["Snares_Casted_Melee"] = "Snares: Melee"

	L["EnableGladiusGloss"] = "Enable Gladius Gloss on Class Icon"
	L["lossOfControl"] = "Blizzard Loss of Control"
	L["lossOfControlInterrupt"] = "Blizzard LOC: Interrupt"
	L["player"] = "Player"
	L["pet"]    = "Pet"
	L["target"] = "Target"
	L["targettarget"] = "TargetTarget"
	L["focus"]  = "Focus"
	L["focustarget"] = "FocusTarget"
	L["party"]  = "Party"
	L["party1"] = "Party 1"
	L["party2"] = "Party 2"
	L["party3"] = "Party 3"
	L["party4"] = "Party 4"
	L["arena"]  = "Arena Enemies"
	L["arena1"] = "Arena Enemy 1"
	L["arena2"] = "Arena Enemy 2"
	L["arena3"] = "Arena Enemy 3"
	L["arena4"] = "Arena Enemy 4"
	L["arena5"] = "Arena Enemy 5"
	L["None"] = "None"
	L["Unit Configuration"] = "Unit Configuration"
	L["Enabled"] = "Enabled"
	L["DisableInBG"] = "Disable in Battlegrounds"
	L["DisableInRaid"] = "Disable in raid group (never in arena)"
	L["DisableInterrupts"] = "Disable Interrupt category for this unit"
	L["ShowNPCInterrupts"] = "Also show Interrupts for NPC units"
	L["DisablePlayerTargetTarget"] = "Disable if unit is Player"
	L["DisableTargetTargetTarget"] = "Disable if unit is Target"
	L["DisablePlayerTargetPlayerTargetTarget"] = "Disabe if unit and Target are Player"
	L["DisableTargetDeadTargetTarget"] = "Disable if Target is a dead unit"
	L["DisableFocusFocusTarget"] = "Disable if unit is Focus"
	L["DisablePlayerFocusPlayerFocusTarget"] = "Disabe if unit and Focus are Player"
	L["DisableFocusDeadFocusTarget"] = "Disable if Focus is a dead unit"
	L["DuplicatePlayerPortrait"] = "Duplicate Icon to show in Portrait"
	L["Anchor"] = "Anchor"
	L["CategoriesEnabledLabel"] = "Enabled for the following categories (|cff00ff00[F]|r friendly unit, |cffff0000[E]|r enemy unit, |cff134d56[B]|r helpful aura,|cff543f16[D]|r harmful aura):"
	L["CatFriendly"] = "|cff00ff00[F]|r"
	L["CatEnemy"] = "|cffff0000[E]|r"
	L["CatFriendlyBuff"] = "|cff00ff00[F]|r|cff134d56[B]|r"
	L["CatFriendlyDebuff"] = "|cff00ff00[F]|r|cff543f16[D]|r"
	L["CatEnemyBuff"] = "|cffff0000[E]|r|cff134d56[B]|r"
	L["CatEnemyDebuff"] = "|cffff0000[E]|r|cff543f16[D]|r"
	L["Strata"] = "Strata"
	L["Icon Size"] = "Icon Size"
	L["Opacity"] = "Opacity"
	L["Unlock"] = "Unlock"
	L["ReloadUI"] = "ReloadUI"
	L[" (drag an icon to move)"] = " (drag icons)"
	L["Disable OmniCC Support"] = "Disable OmniCC Support"
	L["Disable Blizzard Countdown"] = "Disable Blizzard Countdown"
	L["DisableLossOfControlCooldownText"] = "Disable Cooldown on player bars for CC effects"
	L["NeedsReload"] = "Needs ReloadUI to take effect"
	L["Priority"] = "Priority"
	L["PriorityDescription"] = "Set the priority for each spell category below. Higher numbers have more priority. 0 disables the category."
	L["LoseControl reset."] = "|cff00ccffLoseControl |r"..": Reset. Some changes require a UI reload"
end
