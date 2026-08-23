# rs-shops

Beveiligde winkels voor ESX en ox_inventory. Prijzen, locaties, aantallen, afstand, saldo en draagruimte worden server-side gecontroleerd. Contant en bank betalen worden ondersteund.

## Installatie

Start na `es_extended`, `ox_lib`, `ox_inventory` en `oxmysql`. De transactietabel wordt automatisch aangemaakt. Pas assortimenten en locaties aan in `config.lua`.

Optionele Discord-logging:

```cfg
set rs_shops_webhook "DISCORD_WEBHOOK"
```

Stop `esx_shops` pas nadat alle locaties en items zijn getest.
