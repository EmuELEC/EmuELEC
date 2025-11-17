var app = {
	currentSystem: null,
	allGames: [],
	systems: [],
	currentGameDetail: null,
	currentView: 'games',
	currentConfigPath: '',
	configContent: '',
	scrapingInProgress: false,
	scrapingCheckInterval: null,

	init: function() {
		this.loadSystems();
		this.updateStatus();
		var self = this;
		setInterval(function() { self.updateStatus(); }, 5000);
		this.populateSystemSelects();
	},

	request: function(method, endpoint, body, contentType) {
		var xhr = new XMLHttpRequest();
		xhr.open(method, endpoint, false);
		
		if (body && contentType) {
			xhr.setRequestHeader('Content-Type', contentType);
		}
		
		try {
			xhr.send(body || null);
			return xhr;
		} catch (error) {
			console.error('Request failed:', error);
			this.showNotificationBanner('Request failed: ' + error.message, 'error');
			return null;
		}
	},

	loadSystems: function() {
		var xhr = this.request('GET', '/systems');
		if (xhr && xhr.status === 200) {
			var systems = JSON.parse(xhr.responseText);
			this.systems = systems;
			this.displaySystems(systems);
		}
	},

	displaySystems: function(systems) {
		var html = '';
		for (var i = 0; i < systems.length; i++) {
			var s = systems[i];
			if (s.visible === 'true') {
				html += '<div class="system-item" onclick="app.selectSystem(\'' + s.name + '\')">';
				if (s.logo) {
					html += '<img src="' + s.logo + '" alt="' + s.fullname + '">';
				} else {
					html += '<span>[ ]</span>';
				}
				html += '<div class="system-info">';
				html += '<div class="system-name">' + s.fullname + '</div>';
				html += '<div class="system-count">' + (s.totalGames || 0) + ' games</div>';
				html += '</div></div>';
			}
		}
		document.getElementById('systemList').innerHTML = html;
	},

	selectSystem: function(systemName) {
		this.currentSystem = systemName;
		var items = document.querySelectorAll('.system-item');
		for (var i = 0; i < items.length; i++) {
			items[i].classList.remove('active');
		}
		if (event.target.closest) {
			event.target.closest('.system-item').classList.add('active');
		}

		document.getElementById('gamesContainer').innerHTML = '<div class="loading"><div class="spinner"></div><p>Loading games...</p></div>';

		var xhr = this.request('GET', '/systems/' + systemName + '/games');
		if (xhr && xhr.status === 200) {
			var games = JSON.parse(xhr.responseText);
			this.allGames = games;
			this.filterGames(); // Apply current filters instead of directly sorting
		}
	},

	displayGames: function(games) {
		if (games.length === 0) {
			document.getElementById('gamesContainer').innerHTML = 
				'<div class="empty-state">' +
				'<div class="empty-state-icon">[ ]</div>' +
				'<h3>No games found</h3>' +
				'</div>';
			return;
		}

		var html = '<div class="grid">';
		for (var i = 0; i < games.length; i++) {
			var g = games[i];
			var escapedPath = g.path.replace(/'/g, "\\'");
			var isFavorite = g.favorite === 'true' || g.favorite === true;
			var heartIcon = isFavorite ? '&#10084;' : '&#9825;';
			var heartColor = isFavorite ? '#ef4444' : '#94a3b8';
			
			html += '<div class="game-card">';
			html += '<div class="game-image">';
			if (g.image) {
				html += '<img src="' + g.image + '" alt="' + g.name + '" loading="lazy">';
			} else {
				html += '<div class="game-image-placeholder">*</div>';
			}
			html += '</div>';
			html += '<div class="game-info">';
			html += '<div class="game-name" title="' + g.name + '">' + g.name + '</div>';
			if (g.desc) {
				html += '<div class="game-desc">' + g.desc + '</div>';
			}
			
			// Add metadata info
			var metaInfo = [];
			
			// Year
			if (g.releasedate) {
				var year = g.releasedate.substring(0, 4);
				metaInfo.push('Year: ' + year);
			}
			
			// Developer/Publisher
			var devPub = [];
			if (g.developer) devPub.push(g.developer);
			if (g.publisher) devPub.push(g.publisher);
			if (devPub.length > 0) {
				metaInfo.push('By: ' + devPub.join('/'));
			}
			
			// Platform
			if (this.currentSystem) {
				var systemName = '';
				for (var j = 0; j < this.systems.length; j++) {
					if (this.systems[j].name === this.currentSystem) {
						systemName = this.systems[j].fullname;
						break;
					}
				}
				if (systemName) {
					metaInfo.push('Platform: ' + systemName);
				}
			}
			
			// Genre
			if (g.genre) {
				metaInfo.push('Genre: ' + g.genre);
			}
			
			// Play count
			if (g.playcount) {
				metaInfo.push('Play count: ' + g.playcount);
			}
			
			// Cheevos
			var hasCheevos = (g.cheevosHash && g.cheevosHash !== '') && (g.cheevosId && g.cheevosId !== '');
			metaInfo.push('Cheevos: ' + (hasCheevos ? 'Yes' : 'No'));
			
			if (metaInfo.length > 0) {
				html += '<div class="game-meta">' + metaInfo.join(' | ') + '</div>';
			}
			
			html += '</div>';
			html += '<div class="game-actions">';
			html += '<button class="game-btn game-btn-play" onclick="app.launchGame(\'' + escapedPath + '\')">Play</button>';
			html += '<button class="game-btn game-btn-favorite" onclick="app.toggleFavorite(\'' + escapedPath + '\')" style="background: white; border: 2px solid ' + heartColor + '; color: ' + heartColor + ';">' + heartIcon + '</button>';
			html += '<button class="game-btn game-btn-info" onclick="app.showGameDetails(\'' + escapedPath + '\')">Info</button>';
			html += '<button class="game-btn game-btn-scrape" onclick="app.scrapeGame(\'' + escapedPath + '\')">Scrape</button>';
			html += '</div></div>';
		}
		html += '</div>';
		document.getElementById('gamesContainer').innerHTML = html;
	},

	filterGames: function() {
		var searchInput = document.getElementById('searchInput');
		var filterFieldSelect = document.getElementById('filterField');
		var invertFilterCheckbox = document.getElementById('invertFilter');
		
		// If elements don't exist yet, just sort and display all games
		if (!searchInput || !filterFieldSelect || !invertFilterCheckbox) {
			this.sortAndDisplayGames(this.allGames);
			return;
		}
		
		var search = searchInput.value.toLowerCase();
		var filterField = filterFieldSelect.value;
		var invertFilter = invertFilterCheckbox.checked;
		var filtered = [];
		
		for (var i = 0; i < this.allGames.length; i++) {
			var g = this.allGames[i];
			
			// Apply search filter
			var matchesSearch = !search || 
				g.name.toLowerCase().indexOf(search) !== -1 || 
				(g.desc && g.desc.toLowerCase().indexOf(search) !== -1);
			
			if (!matchesSearch) continue;
			
			// Apply metadata filter
			var matchesFilter = true;
			
			if (filterField) {
				if (filterField === 'notscraped') {
					// Game is "not scraped" if it lacks both image and video
					var hasImage = g.image && g.image !== '';
					var hasVideo = g.video && g.video !== '';
					matchesFilter = !hasImage && !hasVideo;
				} else if (filterField === 'favorite') {
					// Special handling for favorite - check if it's true
					matchesFilter = (g.favorite === 'true' || g.favorite === true);
				} else if (filterField === 'hascheevos') {
					// Check if both cheevosHash and cheevosId are filled
					var hasCheevosHash = g.cheevosHash && g.cheevosHash !== '';
					var hasCheevosId = g.cheevosId && g.cheevosId !== '';
					matchesFilter = hasCheevosHash && hasCheevosId;
				}
				
				// Invert filter if checkbox is checked
				if (invertFilter) {
					matchesFilter = !matchesFilter;
				}
			}
			
			if (matchesFilter) {
				filtered.push(g);
			}
		}
		
		this.sortAndDisplayGames(filtered);
	},

	sortGames: function() {
		this.filterGames();
	},

	sortAndDisplayGames: function(games) {
		var sortField = document.getElementById('sortField').value;
		var sortOrder = document.getElementById('sortOrder').value;
		
		games.sort(function(a, b) {
			var aVal = a[sortField];
			var bVal = b[sortField];
			
			if (aVal === undefined) aVal = '';
			if (bVal === undefined) bVal = '';
			
			if (sortField === 'rating' || sortField === 'playcount' || sortField === 'gametime' || sortField === 'players') {
				aVal = parseFloat(aVal) || 0;
				bVal = parseFloat(bVal) || 0;
			}
			
			if (sortField === 'favorite') {
				aVal = (aVal === 'true' || aVal === true) ? 1 : 0;
				bVal = (bVal === 'true' || bVal === true) ? 1 : 0;
			}
			
			var comparison = 0;
			if (aVal > bVal) comparison = 1;
			else if (aVal < bVal) comparison = -1;
			
			return sortOrder === 'desc' ? -comparison : comparison;
		});
		
		this.displayGames(games);
	},

	toggleFavorite: function(gamePath) {
		var game = null;
		for (var i = 0; i < this.allGames.length; i++) {
			if (this.allGames[i].path === gamePath) {
				game = this.allGames[i];
				break;
			}
		}
		if (!game) return;
		
		var isFavorite = game.favorite === 'true' || game.favorite === true;
		var newFavorite = !isFavorite;
		
		var gameJson = JSON.stringify({
			favorite: newFavorite.toString()
		});
		
		var xhr = this.request('POST', '/systems/' + this.currentSystem + '/games/' + game.id, gameJson, 'application/json');
		
		if (xhr && xhr.status === 200) {
			game.favorite = newFavorite.toString();
			this.filterGames();
			this.showNotificationBanner(newFavorite ? 'Added to favorites' : 'Removed from favorites', 'success');
		} else {
			this.showNotificationBanner('Failed to update favorite status', 'error');
		}
	},

	scrapeGame: function(gamePath) {
		var game = null;
		for (var i = 0; i < this.allGames.length; i++) {
			if (this.allGames[i].path === gamePath) {
				game = this.allGames[i];
				break;
			}
		}
		if (!game) return;
		
		if (!confirm('Scrape metadata and media for: ' + game.name + '?')) {
			return;
		}
		
		var xhr = this.request('POST', '/scrape/' + this.currentSystem, game.path, 'text/plain');
		
		if (xhr && xhr.status === 200) {
			this.showNotificationBanner('Scraping started for ' + game.name, 'info');
			this.startScrapingMonitor();
		} else if (xhr && xhr.status === 409) {
			this.showNotificationBanner('Scraper is already running. Please wait for it to finish.', 'error');
		} else if (xhr && xhr.status === 404) {
			this.showNotificationBanner('Game not found.', 'error');
		} else {
			this.showNotificationBanner('Failed to start scraping', 'error');
		}
	},

	scrapeSystem: function() {
		if (!this.currentSystem) {
			this.showNotificationBanner('Please select a system first', 'error');
			return;
		}
		
		if (!confirm('Scrape all games in ' + this.currentSystem + '?\n\nThis may take a long time depending on the number of games.')) {
			return;
		}
		
		var xhr = this.request('POST', '/scrape/' + this.currentSystem);
		
		if (xhr && xhr.status === 200) {
			this.showNotificationBanner('System scraping started. Monitoring progress...', 'info');
			this.startScrapingMonitor();
		} else if (xhr && xhr.status === 409) {
			this.showNotificationBanner('Scraper is already running. Please wait for it to finish.', 'error');
		} else {
			this.showNotificationBanner('Failed to start system scraping', 'error');
		}
	},

	startScrapingMonitor: function() {
		if (this.scrapingInProgress) {
			return;
		}
		
		this.scrapingInProgress = true;
		document.getElementById('statusText').textContent = 'Scraping...';
		
		var self = this;
		this.scrapingCheckInterval = setInterval(function() {
			self.checkScrapingStatus();
		}, 2000);
	},

	checkScrapingStatus: function() {
		var xhr = this.request('GET', '/isIdle');
		
		if (xhr && xhr.status === 200) {
			try {
				var isIdle = JSON.parse(xhr.responseText);
				
				if (isIdle[0] === true) {
					this.stopScrapingMonitor();
					
					/*
					 if (confirm('Scraping completed!\n\nWould you like to reload the games list to see the updated metadata?')) {
						var currentSys = this.currentSystem;
						this.reloadGames();
						
						// Reload the current system view after a delay to allow ES to process
						if (currentSys) {
							var self = this;
							setTimeout(function() {
								self.selectSystem(currentSys);
							}, 2000);
						}
					}
					*/ 
					
					this.showNotificationBanner('Scraping completed! Click "Reload Games" to see the updated metadata.', 'success');
				}
			} catch (e) {
				console.error('Failed to parse isIdle response:', e);
			}
		}
	},

	stopScrapingMonitor: function() {
		if (this.scrapingCheckInterval) {
			clearInterval(this.scrapingCheckInterval);
			this.scrapingCheckInterval = null;
		}
		this.scrapingInProgress = false;
		document.getElementById('statusText').textContent = 'Ready';
	},

	reloadCurrentSystem: function() {
		if (this.currentSystem) {
			var systemName = this.currentSystem;
			this.currentSystem = null;
			this.selectSystem(systemName);
			// selectSystem now calls filterGames() which will apply current filters
		}
	},

	launchGame: function(gamePath) {
		var xhr = this.request('POST', '/launch', gamePath, 'text/plain');
		if (xhr && xhr.status === 200) {
			this.showNotificationBanner('Game launched!', 'success');
			this.updateStatus();
		} else {
			this.showNotificationBanner('Failed to launch game', 'error');
		}
	},

	showGameDetails: function(gamePath) {
		var game = null;
		for (var i = 0; i < this.allGames.length; i++) {
			if (this.allGames[i].path === gamePath) {
				game = this.allGames[i];
				break;
			}
		}
		if (!game) return;

		this.currentGameDetail = game;

		var modalBody = '<div class="tabs">' +
			'<button class="tab active" onclick="app.showTab(\'info\')">Info</button>' +
			'<button class="tab" onclick="app.showTab(\'media\')">Media</button>' +
			'</div><div id="tabContent"></div>';

		document.getElementById('modalTitle').textContent = game.name;
		document.getElementById('modalBody').innerHTML = modalBody;
		document.getElementById('gameModal').classList.add('active');
		
		this.showInfoTab();
	},

	showTab: function(tab) {
		var tabs = document.querySelectorAll('.tab');
		for (var i = 0; i < tabs.length; i++) {
			tabs[i].classList.remove('active');
		}
		event.target.classList.add('active');

		var tabContent = document.getElementById('tabContent');
		if (tab === 'media') {
			this.showMediaTab();
		} else {
			this.showInfoTab();
		}
	},

	showInfoTab: function() {
		var game = this.currentGameDetail;
		if (!game) return;

		var html = '<div class="form-group">' +
			'<label class="form-label">Name</label>' +
			'<input type="text" class="form-input" value="' + game.name + '" readonly>' +
			'</div>' +
			'<div class="form-group">' +
			'<label class="form-label">Path</label>' +
			'<input type="text" class="form-input" value="' + game.path + '" readonly>' +
			'</div>';
		
		if (game.desc) {
			html += '<div class="form-group">' +
				'<label class="form-label">Description</label>' +
				'<textarea class="form-textarea" readonly>' + game.desc + '</textarea>' +
				'</div>';
		}
		if (game.developer) {
			html += '<div class="form-group">' +
				'<label class="form-label">Developer</label>' +
				'<input type="text" class="form-input" value="' + game.developer + '" readonly>' +
				'</div>';
		}
		if (game.publisher) {
			html += '<div class="form-group">' +
				'<label class="form-label">Publisher</label>' +
				'<input type="text" class="form-input" value="' + game.publisher + '" readonly>' +
				'</div>';
		}
		if (game.releasedate) {
			html += '<div class="form-group">' +
				'<label class="form-label">Release Date</label>' +
				'<input type="text" class="form-input" value="' + game.releasedate + '" readonly>' +
				'</div>';
		}
		if (game.genre) {
			html += '<div class="form-group">' +
				'<label class="form-label">Genre</label>' +
				'<input type="text" class="form-input" value="' + game.genre + '" readonly>' +
				'</div>';
		}
		if (game.players) {
			html += '<div class="form-group">' +
				'<label class="form-label">Players</label>' +
				'<input type="text" class="form-input" value="' + game.players + '" readonly>' +
				'</div>';
		}
		if (game.playcount) {
			html += '<div class="form-group">' +
				'<label class="form-label">Play Count</label>' +
				'<input type="text" class="form-input" value="' + game.playcount + '" readonly>' +
				'</div>';
		}
		if (game.rating) {
			html += '<div class="form-group">' +
				'<label class="form-label">Rating</label>' +
				'<input type="text" class="form-input" value="' + game.rating + '" readonly>' +
				'</div>';
		}

		document.getElementById('tabContent').innerHTML = html;
	},

	showMediaTab: function() {
		var game = this.currentGameDetail;
		if (!game) return;

		var mediaTypes = [
			{ key: 'image', label: 'Image' },
			{ key: 'thumbnail', label: 'Thumbnail' },
			{ key: 'marquee', label: 'Marquee' },
			{ key: 'fanart', label: 'Fan Art' },
			{ key: 'boxback', label: 'Box Back' },
			{ key: 'video', label: 'Video' },
			{ key: 'manual', label: 'Manual' }
		];

		var html = '<div class="media-grid">';
		
		for (var i = 0; i < mediaTypes.length; i++) {
			var media = mediaTypes[i];
			if (game[media.key]) {
				html += '<div class="media-item">';
				if (media.key === 'video') {
					html += '<video controls style="width:100%;height:100%;object-fit:cover;">' +
						'<source src="' + game[media.key] + '" type="video/mp4">' +
						'Video not supported' +
						'</video>';
				} else if (media.key === 'manual') {
					html += '<div style="display:flex;flex-direction:column;align-items:center;justify-content:center;height:100%;padding:10px;">' +
						'<div style="font-size:24px;margin-bottom:8px;">PDF</div>' +
						'<a href="' + game[media.key] + '" target="_blank" style="color:#84849f;text-decoration:none;font-size:12px;">View Manual</a>' +
						'</div>';
				} else {
					html += '<img src="' + game[media.key] + '" alt="' + media.label + '" loading="lazy">';
				}
				html += '<div style="position:absolute;bottom:0;left:0;right:0;background:rgba(0,0,0,0.7);color:white;padding:8px;font-size:12px;text-align:center;">' + 
					media.label + '</div>';
				html += '</div>';
			}
		}
		
		html += '</div>';

		if (html === '<div class="media-grid"></div>') {
			html = '<div class="empty-state"><div class="empty-state-icon">[ ]</div><h3>No media available</h3></div>';
		}

		document.getElementById('tabContent').innerHTML = html;
	},

	closeModal: function() {
		document.getElementById('gameModal').classList.remove('active');
	},

	showNotificationBanner: function(message, type) {
		var banner = document.getElementById('notificationBanner');
		var notificationText = document.getElementById('notificationText');
		
		if (!banner || !notificationText) {
			console.error('Notification banner elements not found');
			return;
		}
		
		// Remove existing type classes
		banner.className = 'notification-banner';
		
		// Add type-specific class
		if (type === 'success') {
			banner.classList.add('notification-success');
		} else if (type === 'error') {
			banner.classList.add('notification-error');
		} else if (type === 'info') {
			banner.classList.add('notification-info');
		}
		
		notificationText.textContent = message;
		banner.style.display = 'flex';
		
		// Auto-hide after 5 seconds
		setTimeout(function() {
			banner.style.display = 'none';
		}, 5000);
	},
/*

showNotificationBanner: function(message, type) {
	// Create banner if it doesn't exist
	var banner = document.getElementById('notificationBanner');
	if (!banner) {
		banner = document.createElement('div');
		banner.id = 'notificationBanner';
		banner.style.cssText = 'position:fixed;top:20px;right:20px;padding:15px 20px;border-radius:8px;' +
			'color:white;font-size:14px;z-index:10000;box-shadow:0 4px 6px rgba(0,0,0,0.3);' +
			'transition:opacity 0.3s ease;max-width:400px;';
		document.body.appendChild(banner);
	}
	
	// Set color based on type
	var bgColor;
	if (type === 'success') {
		bgColor = '#10b981'; // green
	} else if (type === 'error') {
		bgColor = '#ef4444'; // red
	} else if (type === 'info') {
		bgColor = '#3b82f6'; // blue
	} else {
		bgColor = '#6b7280'; // gray
	}
	
	banner.style.backgroundColor = bgColor;
	banner.textContent = message;
	banner.style.opacity = '1';
	banner.style.display = 'block';
	
	// Auto-hide after 3 seconds
	setTimeout(function() {
		banner.style.opacity = '0';
		setTimeout(function() {
			banner.style.display = 'none';
		}, 500);
	}, 5000);
},
*/

	updateStatus: function() {
		var xhr = this.request('GET', '/runningGame');
		if (xhr && xhr.status === 200) {
			var text = xhr.responseText;
			var runningDiv = document.getElementById('runningGame');
			var runningText = document.getElementById('runningGameText');
			
			if (text && text !== 'null' && text !== '') {
				try {
					var gameData = JSON.parse(text);
					var displayText = gameData.name;
					if (gameData.systemName) {
						displayText += ', System: ' + gameData.systemName.toUpperCase();
					}
					runningDiv.style.display = 'flex';
					runningText.textContent = displayText;
					document.getElementById('statusText').textContent = 'Playing';
				} catch (e) {
					runningDiv.style.display = 'flex';
					runningText.textContent = text;
					document.getElementById('statusText').textContent = 'Playing';
				}
			} else {
				runningDiv.style.display = 'none';
				document.getElementById('statusText').textContent = 'Ready';
			}
		}
	},

	reloadGames: function() {
		if (confirm('Reload all game lists?')) {
			this.request('GET', '/reloadgames');
			this.showNotificationBanner('Games reloaded!', 'success');
			this.loadSystems();
		}
	},

	killEmulator: function() {
		if (confirm('Kill the running emulator?')) {
			this.request('GET', '/emukill');
			this.showNotificationBanner('Emulator killed!', 'success');
			this.updateStatus();
		}
	},

	restart: function() {
		if (confirm('Restart EmulationStation?')) {
			this.request('GET', '/restart');
		}
	},

	quit: function() {
		if (confirm('Quit EmulationStation?')) {
			this.request('GET', '/quit');
		}
	},

	showMessageBox: function() {
		var message = prompt('Enter message to display:');
		if (message) {
			this.request('POST', '/messagebox', message, 'text/plain');
		}
	},

	showNotification: function() {
		var message = prompt('Enter notification text:');
		if (message) {
			this.request('POST', '/notify', message, 'text/plain');
		}
	},

	showView: function(view) {
		this.currentView = view;
		
		document.getElementById('gamesView').style.display = 'none';
		document.getElementById('configView').style.display = 'none';
		document.getElementById('toolsView').style.display = 'none';
		
		if (view === 'games') {
			document.getElementById('gamesView').style.display = 'flex';
		} else if (view === 'config') {
			document.getElementById('configView').style.display = 'flex';
			this.loadConfigList();
		} else if (view === 'tools') {
			document.getElementById('toolsView').style.display = 'flex';
		}
	},

	loadConfigList: function(subpath) {
		this.currentConfigPath = subpath || '';
		var endpoint = '/config' + (subpath ? '/' + subpath : '');
		
		var xhr = this.request('GET', endpoint);
		if (xhr && xhr.status === 200) {
			try {
				var items = JSON.parse(xhr.responseText);
				this.displayConfigList(items);
			} catch (e) {
				console.error('Failed to parse config list:', e);
			}
		}
	},

	displayConfigList: function(items) {
		items.sort(function(a, b) {
			if (a.isDirectory && !b.isDirectory) return -1;
			if (!a.isDirectory && b.isDirectory) return 1;
			return a.name.localeCompare(b.name);
		});
		
		var html = '';
		
		if (this.currentConfigPath) {
			var parentPath = this.currentConfigPath.split('/').slice(0, -1).join('/');
			html += '<div class="file-list-item" onclick="app.loadConfigList(\'' + parentPath + '\')">';
			html += '<span class="file-icon">&lt;</span>';
			html += '<span class="file-name">..</span>';
			html += '</div>';
		}
		
		for (var i = 0; i < items.length; i++) {
			var item = items[i];
			var icon = item.isDirectory ? '&#128193;' : '&#128196;';
			var onclick = item.isDirectory 
				? 'app.loadConfigList(\'' + item.path + '\')' 
				: 'app.loadConfigFile(\'' + item.path + '\')';
			
			html += '<div class="file-list-item" onclick="' + onclick + '">';
			html += '<span class="file-icon">' + icon + '</span>';
			html += '<span class="file-name">' + item.name + '</span>';
			html += '</div>';
		}
		
		document.getElementById('configList').innerHTML = html;
	},

	loadConfigFile: function(filepath) {
		var xhr = this.request('GET', '/config/' + filepath);
		if (xhr && xhr.status === 200) {
			this.configContent = xhr.responseText;
			this.displayConfigEditor(filepath);
		}
	},

	displayConfigEditor: function(filepath) {
		var breadcrumb = filepath.split('/').join(' / ');
		
		var html = '<div class="config-editor">';
		html += '<div class="config-editor-header">';
		html += '<div class="config-editor-title">' + filepath + '</div>';
		html += '<div class="config-editor-actions">';
		html += '<button class="btn btn-primary" onclick="app.saveConfigFile(\'' + filepath + '\')">Save</button>';
		html += '<button class="btn btn-danger" onclick="app.deleteConfigFile(\'' + filepath + '\')">Delete</button>';
		html += '<button class="btn btn-secondary" onclick="app.closeConfigEditor()">Close</button>';
		html += '</div></div>';
		html += '<textarea class="config-textarea" id="configTextarea">' + this.escapeHtml(this.configContent) + '</textarea>';
		html += '</div>';
		
		document.getElementById('configEditorContainer').innerHTML = html;
	},

	saveConfigFile: function(filepath) {
		var content = document.getElementById('configTextarea').value;
		var xhr = this.request('POST', '/config/' + filepath, content, 'text/plain');
		
		if (xhr && xhr.status === 200) {
			this.showNotificationBanner('File saved successfully!', 'success');
			this.configContent = content;
		} else {
			this.showNotificationBanner('Failed to save file', 'error');
		}
	},

	deleteConfigFile: function(filepath) {
		if (!confirm('Are you sure you want to delete this file?\n\n' + filepath + '\n\nA backup will be created.')) {
			return;
		}
		
		var xhr = new XMLHttpRequest();
		xhr.open('DELETE', '/config/' + filepath, false);
		xhr.send();
		
		if (xhr.status === 200) {
			this.showNotificationBanner('File deleted! Backup saved as .deleted', 'success');
			this.closeConfigEditor();
			this.loadConfigList(this.currentConfigPath);
		} else {
			this.showNotificationBanner('Failed to delete file', 'error');
		}
	},

	closeConfigEditor: function() {
		document.getElementById('configEditorContainer').innerHTML = 
			'<div class="empty-state">' +
			'<div class="empty-state-icon">[ ]</div>' +
			'<h3>Select a config file to edit</h3>' +
			'</div>';
	},

	createNewConfigFile: function() {
		var filename = prompt('Enter filename:');
		if (!filename) return;
		
		var filepath = this.currentConfigPath ? this.currentConfigPath + '/' + filename : filename;
		
		this.configContent = '';
		this.displayConfigEditor(filepath);
	},

	escapeHtml: function(text) {
		var map = {
			'&': '&amp;',
			'<': '&lt;',
			'>': '&gt;',
			'"': '&quot;',
			"'": '&#039;'
		};
		return text.replace(/[&<>"']/g, function(m) { return map[m]; });
	},

	populateSystemSelects: function() {
		var self = this;
		setTimeout(function() {
			if (self.systems.length === 0) return;
			
			var html = '<option value="">-- Select a system --</option>';
			for (var i = 0; i < self.systems.length; i++) {
				var s = self.systems[i];
				if (s.visible === 'true') {
					html += '<option value="' + s.name + '">' + s.fullname + '</option>';
				}
			}
			
			document.getElementById('addGamesSystem').innerHTML = html;
			document.getElementById('removeGamesSystem').innerHTML = html;
			document.getElementById('removeSystemSelect').innerHTML = html;
			document.getElementById('addEmulatorSystem').innerHTML = html;
			document.getElementById('removeEmulatorSystem').innerHTML = html;
		}, 1000);
	},

	addGames: function() {
		var system = document.getElementById('addGamesSystem').value;
		var xml = document.getElementById('addGamesXML').value;
		var result = document.getElementById('addGamesResult');
		
		if (!system) {
			result.textContent = 'Error: Please select a system';
			result.style.display = 'block';
			result.style.color = '#848484';
			return;
		}
		
		if (!xml.trim()) {
			result.textContent = 'Error: Please enter gamelist XML';
			result.style.display = 'block';
			result.style.color = '#848484';
			return;
		}
		
		var xhr = this.request('POST', '/addgames/' + system, xml, 'application/xml');
		
		if (xhr) {
			if (xhr.status === 200) {
				result.textContent = 'Success! Games added/updated. The system will be refreshed.';
				result.style.color = '#84849f';
				document.getElementById('addGamesXML').value = '';
			} else if (xhr.status === 201) {
				result.textContent = 'Games added but system not loaded. Click "Reload Games" to see them.';
				result.style.color = '#b4b1c2';
			} else if (xhr.status === 204) {
				result.textContent = 'No games were added or updated. Check your XML format.';
				result.style.color = '#848484';
			} else if (xhr.status === 404) {
				result.textContent = 'Error: System not found';
				result.style.color = '#848484';
			} else {
				result.textContent = 'Error: ' + xhr.responseText;
				result.style.color = '#848484';
			}
			result.style.display = 'block';
		}
	},

	removeGames: function() {
		var system = document.getElementById('removeGamesSystem').value;
		var xml = document.getElementById('removeGamesXML').value;
		var result = document.getElementById('removeGamesResult');
		
		if (!system) {
			result.textContent = 'Error: Please select a system';
			result.style.display = 'block';
			result.style.color = '#848484';
			return;
		}
		
		if (!xml.trim()) {
			result.textContent = 'Error: Please enter gamelist XML';
			result.style.display = 'block';
			result.style.color = '#848484';
			return;
		}
		
		if (!confirm('WARNING: This will DELETE the ROM files from disk!\n\nAre you sure you want to remove these games?')) {
			return;
		}
		
		var xhr = this.request('POST', '/removegames/' + system, xml, 'application/xml');
		
		if (xhr) {
			if (xhr.status === 200) {
				result.textContent = 'Success! Games removed and files deleted.';
				result.style.color = '#84849f';
				document.getElementById('removeGamesXML').value = '';
			} else if (xhr.status === 204) {
				result.textContent = 'No games were removed. Check your XML format.';
				result.style.color = '#848484';
			} else if (xhr.status === 404) {
				result.textContent = 'Error: System not found';
				result.style.color = '#848484';
			} else {
				result.textContent = 'Error: ' + xhr.responseText;
				result.style.color = '#848484';
			}
			result.style.display = 'block';
		}
	},

	addSystem: function() {
		var xml = document.getElementById('addSystemXML').value;
		var result = document.getElementById('addSystemResult');
		
		if (!xml.trim()) {
			result.textContent = 'Error: Please enter system XML';
			result.style.display = 'block';
			result.style.color = '#848484';
			return;
		}
		
		// Check if <command> tag exists, if not add default
		if (xml.indexOf('<command>') === -1) {
			var defaultCommand = '<command>emuelecRunEmu.sh %ROM% -P%SYSTEM% --core=%CORE% --emulator=%EMULATOR% --controllers="%CONTROLLERSCONFIG%"</command>';
			
			// Find where to insert (before closing </system> or </s> tag)
			var insertPos = xml.lastIndexOf('</system>');
			if (insertPos === -1) {
				insertPos = xml.lastIndexOf('</s>');
			}
			
			if (insertPos !== -1) {
				xml = xml.substring(0, insertPos) + '  ' + defaultCommand + '\n' + xml.substring(insertPos);
			}
		}
		
		var xhr = this.request('POST', '/addsystem', xml, 'application/xml');
		
		if (xhr) {
			if (xhr.status === 200) {
				result.textContent = 'Success! System added/updated. Systems will reload.';
				result.style.color = '#84849f';
				document.getElementById('addSystemXML').value = '';
				
				var self = this;
				setTimeout(function() {
					self.loadSystems();
					self.populateSystemSelects();
				}, 2000);
			} else if (xhr.status === 404) {
				result.textContent = 'Error: es_systems.cfg not found';
				result.style.color = '#848484';
			} else {
				result.textContent = 'Error: ' + xhr.responseText;
				result.style.color = '#848484';
			}
			result.style.display = 'block';
		}
	},

	removeSystem: function() {
		var system = document.getElementById('removeSystemSelect').value;
		var result = document.getElementById('removeSystemResult');
		
		if (!system) {
			result.textContent = 'Error: Please select a system';
			result.style.display = 'block';
			result.style.color = '#848484';
			return;
		}
		
		if (!confirm('Are you sure you want to remove the system: ' + system + '?\n\nThis will NOT delete ROM files.')) {
			return;
		}
		
		var xhr = this.request('POST', '/removesystem/' + system);
		
		if (xhr) {
			if (xhr.status === 200) {
				result.textContent = 'Success! System removed. Systems will reload.';
				result.style.color = '#84849f';
				document.getElementById('removeSystemSelect').value = '';
				
				var self = this;
				setTimeout(function() {
					self.loadSystems();
					self.populateSystemSelects();
				}, 2000);
			} else if (xhr.status === 404) {
				result.textContent = 'Error: System or es_systems.cfg not found';
				result.style.color = '#848484';
			} else {
				result.textContent = 'Error: ' + xhr.responseText;
				result.style.color = '#848484';
			}
			result.style.display = 'block';
		}
	},

	addEmulator: function() {
		var system = document.getElementById('addEmulatorSystem').value;
		var xml = document.getElementById('addEmulatorXML').value;
		var result = document.getElementById('addEmulatorResult');
		
		if (!system) {
			result.textContent = 'Error: Please select a system';
			result.style.display = 'block';
			result.style.color = '#848484';
			return;
		}
		
		if (!xml.trim()) {
			result.textContent = 'Error: Please enter emulator XML';
			result.style.display = 'block';
			result.style.color = '#848484';
			return;
		}
		
		var xhr = this.request('POST', '/system/' + system + '/addemulator', xml, 'application/xml');
		
		if (xhr) {
			if (xhr.status === 200) {
				result.textContent = 'Success! Emulator added/updated. Systems will reload.';
				result.style.color = '#84849f';
				document.getElementById('addEmulatorXML').value = '';
			} else if (xhr.status === 404) {
				result.textContent = 'Error: System or es_systems.cfg not found';
				result.style.color = '#848484';
			} else {
				result.textContent = 'Error: ' + xhr.responseText;
				result.style.color = '#848484';
			}
			result.style.display = 'block';
		}
	},

	removeEmulator: function() {
		var system = document.getElementById('removeEmulatorSystem').value;
		var emulator = document.getElementById('removeEmulatorName').value;
		var result = document.getElementById('removeEmulatorResult');
		
		if (!system) {
			result.textContent = 'Error: Please select a system';
			result.style.display = 'block';
			result.style.color = '#848484';
			return;
		}
		
		if (!emulator.trim()) {
			result.textContent = 'Error: Please enter emulator name';
			result.style.display = 'block';
			result.style.color = '#848484';
			return;
		}
		
		if (!confirm('Are you sure you want to remove the emulator: ' + emulator + ' from ' + system + '?')) {
			return;
		}
		
		var xhr = this.request('POST', '/system/' + system + '/removeemulator/' + emulator);
		
		if (xhr) {
			if (xhr.status === 200) {
				result.textContent = 'Success! Emulator removed. Systems will reload.';
				result.style.color = '#84849f';
				document.getElementById('removeEmulatorName').value = '';
			} else if (xhr.status === 404) {
				result.textContent = 'Error: System, emulator, or es_systems.cfg not found';
				result.style.color = '#848484';
			} else {
				result.textContent = 'Error: ' + xhr.responseText;
				result.style.color = '#848484';
			}
			result.style.display = 'block';
		}
	}
};

app.init();

window.onclick = function(event) {
	var modal = document.getElementById('gameModal');
	if (event.target === modal) {
		app.closeModal();
	}
};
