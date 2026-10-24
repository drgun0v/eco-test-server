let backgroundMusic;


window.addEventListener('message', function(event) {
    if (event.data.action == "openMenu") {
        document.body.style.display = "flex";
        document.getElementById('menu-container').style.display = "flex";
        document.getElementById('crafting-container').style.display = "none";
        createMenu(event.data.items);
        if (event.data.playMusic) {
            playBackgroundMusic(event.data.volume);
        }
    } else if (event.data.action == "closeMenu") {
        document.getElementById('menu-container').style.display = "none";
        stopBackgroundMusic();
        if (document.getElementById('crafting-container').style.display === "none") {
            document.body.style.display = "none";
        }
    } else if (event.data.action == "openCrafting") {
        document.body.style.display = "flex";
        document.getElementById('crafting-container').style.display = "flex";
        document.getElementById('menu-container').style.display = "none";
        
        // Pass menuType to differentiate between food and drink
        createCraftingMenu(event.data.recipes, event.data.menuType); // added menuType here

        if (event.data.playMusic) {
            playBackgroundMusic(event.data.volume);
        }
    } else if (event.data.action == "closeCrafting") {
        document.getElementById('crafting-container').style.display = "none";
        stopBackgroundMusic();
        if (document.getElementById('menu-container').style.display === "none") {
            document.body.style.display = "none";
        }
    } else if (event.data.action == "notify") {
        showNotification(event.data.message, event.data.type);
    }
});


document.getElementById('close-button').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    }).then(resp => resp.json()).then(resp => {
        if (resp == 'ok') {
            document.getElementById('menu-container').style.display = "none";
            stopBackgroundMusic();
            if (document.getElementById('crafting-container').style.display === "none") {
                document.body.style.display = "none";
            }
        }
    });
});

document.getElementById('close-crafting-button').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/closeCrafting`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    }).then(resp => resp.json()).then(resp => {
        if (resp == 'ok') {
            document.getElementById('crafting-container').style.display = "none";
            stopBackgroundMusic();
            if (document.getElementById('menu-container').style.display === "none") {
                document.body.style.display = "none";
            }
        }
    });
});

function createMenu(items) {
    const menu = document.getElementById('menu');
    menu.innerHTML = '';
    items.forEach(item => {
        const menuItem = document.createElement('div');
        menuItem.className = 'menu-item';
        menuItem.id = item.id;

        const itemImg = document.createElement('img');
        itemImg.src = item.img;
        itemImg.alt = item.name;

        const itemName = document.createElement('span');
        itemName.innerText = item.name;

        const itemPrice = document.createElement('span');
        itemPrice.className = 'item-price';
        itemPrice.innerText = `$${item.price}`;

        const quantityInput = document.createElement('input');
        quantityInput.type = 'number';
        quantityInput.min = '1';
        quantityInput.value = '1';

        const purchaseButton = document.createElement('button');
        purchaseButton.innerText = 'Purchase';

        purchaseButton.addEventListener('click', function() {
            const clickSound = new Audio('sounds/click.mp3');
            clickSound.play();

            const quantity = quantityInput.value;
            console.log(`Purchasing ${quantity} of ${item.id}`);
            fetch(`https://${GetParentResourceName()}/purchase`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({
                    id: item.id,
                    quantity: quantity
                })
            }).then(resp => resp.json()).then(resp => {
                console.log('Purchase response:', resp);
            });
        });

        menuItem.appendChild(itemImg);
        menuItem.appendChild(itemName);
        menuItem.appendChild(itemPrice);
        menuItem.appendChild(quantityInput);
        menuItem.appendChild(purchaseButton);

        menu.appendChild(menuItem);
    });
}

function createCraftingMenu(recipes, menuType) {
    const craftingMenu = document.getElementById('crafting-menu');
    craftingMenu.innerHTML = '';

    recipes.forEach(recipe => {
        const craftingItem = document.createElement('div');
        craftingItem.className = 'crafting-item';
        craftingItem.id = recipe.id;

        const itemImg = document.createElement('img');
        itemImg.src = recipe.img;
        itemImg.alt = recipe.name;

        const itemName = document.createElement('span');
        itemName.innerText = recipe.name.replace(/_/g, ' ');

        const requiredItems = document.createElement('div');
        requiredItems.className = 'required-items';

        recipe.requiredItems.forEach(item => {
            const itemDiv = document.createElement('div');
            itemDiv.innerText = `${item.quantity}x ${item.id.replace(/_/g, ' ')}`;
            requiredItems.appendChild(itemDiv);
        });

        const craftButton = document.createElement('button');
        craftButton.innerText = 'Create';

        craftButton.addEventListener('click', function() {
            const clickSound = new Audio('sounds/click.mp3');
            clickSound.play();

            console.log(`Crafting ${recipe.id} from ${menuType} menu`);

            // Send a different callback based on menuType
            const callbackAction = menuType === 'drink' ? 'craft-drink' : 'craft';
            fetch(`https://${GetParentResourceName()}/${callbackAction}`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({
                    id: recipe.id
                })
            }).then(resp => resp.json()).then(resp => {
                console.log(`${menuType.charAt(0).toUpperCase() + menuType.slice(1)} crafting response:`, resp);
            });
        });

        craftingItem.appendChild(itemImg);
        craftingItem.appendChild(itemName);
        craftingItem.appendChild(requiredItems);
        craftingItem.appendChild(craftButton);

        craftingMenu.appendChild(craftingItem);
    });
}



function showNotification(message, type) {
    const notificationContainer = document.getElementById('notification-container');
    const notification = document.createElement('div');
    notification.className = 'notification';
    notification.classList.add(type);
    notification.innerText = message;

    notificationContainer.appendChild(notification);

    setTimeout(() => {
        notification.remove();
    }, 4000);
}

function playBackgroundMusic(volume) {
    backgroundMusic = new Audio('sounds/background.mp3');
    backgroundMusic.loop = true;
    backgroundMusic.volume = volume;
    backgroundMusic.play();
}

function stopBackgroundMusic() {
    if (backgroundMusic) {
        backgroundMusic.pause();
        backgroundMusic.currentTime = 0;
        backgroundMusic = null;
    }
}

document.getElementById('more-info-button').addEventListener('click', function() {
    document.getElementById('info-container').style.display = 'flex';
    document.getElementById('crafting-container').style.display = 'none';
});

document.getElementById('close-info-button').addEventListener('click', function() {
    document.getElementById('info-container').style.display = 'none';
    document.getElementById('crafting-container').style.display = 'flex';
});
