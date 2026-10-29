# tdev_bus

Networked bus travel for FiveM.

## What changed in 2.0.0

- The bus is no longer a teleport. A networked NPC driver now drives the bus to the selected stop.
- Other players can board the same active bus by standing near it and pressing `F`.
- Framework support is automatic for ESX, QBCore, and Qbox.
- Inventory support is automatic for `ox_inventory`, ESX inventory, QBCore inventory, and Qbox-compatible inventory.
- Ticket checks/removal happen on the server.
- Routes have cooldowns, distance validation, timeout cleanup, passenger authorization, and driver-host reassignment if the controlling player disconnects.

## Install

1. Put `tdev_bus` in your resources folder.
2. Ensure your framework/inventory starts before this resource when tickets are enabled.
3. Add this to `server.cfg`:

```cfg
ensure tdev_bus
```

4. Configure `config.lua`.

`Config.Framework = 'auto'` detects `es_extended`, `qb-core`, or `qbx_core`.

`Config.Inventory = 'auto'` prefers `ox_inventory` when it is running, then falls back to the detected framework inventory.

Set `Config.TicketRequired = false` if you want free bus rides.

## Ticket Item

Default item name:

```lua
Config.TicketItem = 'bus_ticket'
```

For `ox_inventory`, add this item to `ox_inventory/data/items.lua`:

```lua
['bus_ticket'] = {
    label = 'Bus Ticket',
    weight = 0,
    stack = true,
    close = true,
    description = 'A ticket for bus travel.'
}
```

For QBCore, add a matching item to `qb-core/shared/items.lua` and place `bus_ticket.png` in your inventory images folder.

For ESX database inventory, add `bus_ticket` to your items table.

## Usage

- Go to a bus stop and press `E`.
- Use left/right arrows to choose a destination.
- Press Enter to call the bus.
- Other players with tickets can board the same bus by pressing `F` near it.

## Notes

This resource expects a modern OneSync server for stable networked entity behavior.

If an NPC route gets stuck, the driver task is retried several times before the route is safely cleaned up.
