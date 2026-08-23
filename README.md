# rs-shops

Beveiligde winkels voor ESX en ox_inventory. Prijzen, locaties, aantallen, afstand, saldo en draagruimte worden server-side gecontroleerd. Contant en bank betalen worden ondersteund.

## Installatie

Start na `es_extended`, `ox_lib`, `ox_inventory` en `oxmysql`. De transactietabel wordt automatisch aangemaakt. Pas assortimenten en locaties aan in `config.lua`.

Optionele Discord-logging:

```cfg
set rs_shops_webhook "DISCORD_WEBHOOK"
```

Stop `esx_shops` pas nadat alle locaties en items zijn getest.

## Koppeling met rs-businesses

Als `rs-businesses` aanwezig is, schakelt `rs-shops` een locatie automatisch uit zodra dat bedrijf door een speler is gekocht. Zowel de kaartblip als de `ox_target`-winkelzone verdwijnen. De server weigert daarna ook rechtstreekse aankoop-events op die locatie.

De locatie wordt herkend aan de coördinaten. De maximale afstand staat in `Config.BusinessIntegration.matchDistance`. Start de resources in deze volgorde:

```cfg
ensure rs-shops
ensure rs-businesses
```

Wanneer het bedrijf wordt verwijderd of weer onverkocht wordt gemaakt, plaatst `rs-shops` de oorspronkelijke blip en winkelzone automatisch terug.
