// Tracks the currently selected item index
let currentIndex = 0;

// Holds all clickable menu items
let menuItems = [];

// Tracks whether user is in a sub-menu or main menu
let isInSubMenu = false;

document.addEventListener('DOMContentLoaded', () => {
    // Get UI elements
    const menu = document.getElementById('menu');
    const mainMenu = document.getElementById('mainMenu');
    const subMenu = document.getElementById('subMenu');
    const itemsContainer = document.getElementById('items');
    const backBtn = document.querySelector('.back-btn');
    const pageInfo = document.getElementById('pageInfo');

    // Listen for messages from Lua (NUI callbacks)
    window.addEventListener('message', (e) => {
        if (e.data.action === 'open') {
            menu.classList.add('open');

            // If a list is received, go directly to the submenu
            if (e.data.list && e.data.list.length > 0) {
                showSubMenu(e.data.list);
            } else {
                showMainMenu();
            }
        }
    });

    // Main menu category click events
    document.querySelectorAll('.cat').forEach(cat => {
        cat.addEventListener('click', () => {
            // Cancel animation option
            if (cat.classList.contains('cancel')) {
                fetch(`https://${GetParentResourceName()}/cancelAnim`, { method: 'POST' });
                return;
            }

            // Load the selected category list from Lua
            const type = cat.getAttribute('data-cat');
            if (type) {
                fetch(`https://${GetParentResourceName()}/getList`, {
                    method: 'POST',
                    body: JSON.stringify({ type })
                });
            }
        });
    });

    // Back button returns to main menu
    backBtn.addEventListener('click', showMainMenu);

    // Show main category menu
    function showMainMenu() {
        mainMenu.style.display = 'block';
        subMenu.style.display = 'none';
        isInSubMenu = false;

        // Make main menu items selectable via keyboard
        menuItems = [backBtn, ...document.querySelectorAll('.cat')];
        currentIndex = 0;

        updateSelection();
        updatePageInfo();
    }

    // Show sub-menu items sent from Lua
    function showSubMenu(list) {
        mainMenu.style.display = 'none';
        subMenu.style.display = 'block';
        isInSubMenu = true;

        // Clear old items
        itemsContainer.innerHTML = '';

        // Create new menu entries
        list.forEach(item => {
            const div = document.createElement('div');
            div.className = 'item menu-item';
            div.textContent = item.label;

            // When clicked, send play request to Lua
            div.onclick = () => {
                fetch(`https://${GetParentResourceName()}/play`, {
                    method: 'POST',
                    body: JSON.stringify(item)
                });
            };

            itemsContainer.appendChild(div);
        });

        // Keyboard navigation setup for submenu
        menuItems = [backBtn, ...document.querySelectorAll('#items .menu-item')];
        currentIndex = 0;

        updateSelection();
        updatePageInfo();
    }

    // Keep selected element visible when navigating with keyboard
    function scrollToSelected() {
        const selected = menuItems[currentIndex];
        if (!selected) return;

        const container = isInSubMenu ? subMenu : mainMenu;

        selected.scrollIntoView({
            behavior: 'smooth',
            block: 'nearest',
            inline: 'nearest'
        });

        const containerTop = container.scrollTop;
        const containerHeight = container.clientHeight;
        const elTop = selected.offsetTop - container.offsetTop;
        const elHeight = selected.offsetHeight;

        // Adjust scrolling when selection goes off screen
        if (elTop < containerTop) {
            container.scrollTop = elTop;
        } else if (elTop + elHeight > containerTop + containerHeight) {
            container.scrollTop = elTop + elHeight - containerHeight;
        }
    }

    // Updates highlighted item
    function updateSelection() {
        menuItems.forEach((el, i) => {
            if (i === currentIndex) {
                el.classList.add('selected');
            } else {
                el.classList.remove('selected');
            }
        });

        scrollToSelected();
    }

    // Updates the "x/y" page indicator
    function updatePageInfo() {
        if (menuItems.length <= 1) {
            pageInfo.textContent = '1/1';
            return;
        }

        const totalItems = menuItems.length - 1;
        const current = currentIndex === 0 ? 1 : currentIndex;
        pageInfo.textContent = `${current}/${totalItems}`;
    }

    // Keyboard navigation (↑ ↓ Enter Backspace)
    document.addEventListener('keydown', (e) => {
        if (!menu.classList.contains('open')) return;

        switch (e.key) {
            case 'ArrowUp':
                e.preventDefault();
                currentIndex = currentIndex <= 0 ? menuItems.length - 1 : currentIndex - 1;
                updateSelection();
                updatePageInfo();
                break;

            case 'ArrowDown':
                e.preventDefault();
                currentIndex = currentIndex >= menuItems.length - 1 ? 0 : currentIndex + 1;
                updateSelection();
                updatePageInfo();
                break;

            case 'Enter':
                e.preventDefault();
                if (menuItems[currentIndex]) {
                    menuItems[currentIndex].click();
                }
                break;

            case 'Backspace':
                e.preventDefault();

                // Back from submenu → main menu
                if (isInSubMenu) {
                    showMainMenu();
                } 
                // Back from main menu → close NUI
                else {
                    fetch(`https://${GetParentResourceName()}/closeMenu`, { method: 'POST' });
                    menu.classList.remove('open');
                }
                break;
        }
    });
});
