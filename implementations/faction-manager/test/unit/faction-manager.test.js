const FactionManager = require('../../src/index.js');

describe('FactionManager', () => {
  let factionManager;

  beforeEach(async () => {
    factionManager = new FactionManager();
    await factionManager.initialize();
  });

  describe('initializeFaction', () => {
    it('should initialize a new faction with required parameters', async () => {
      const factionData = {
        factionId: 'testFaction',
        name: 'Test Faction'
      };

      const result = await factionManager.initializeFaction(factionData);
      
      expect(result.status).toBe('faction_initialized');
      const balance = await factionManager.getFactionBalance();
      const factionExists = balance.factions.some(f => f.factionId === 'testFaction');
      expect(factionExists).toBe(true);
    });

    it('should throw an error if factionId is missing', async () => {
      const factionData = {
        name: 'Test Faction'
      };

      await expect(factionManager.initializeFaction(factionData))
        .rejects
        .toThrow('Faction ID and name are required');
    });
  });

  describe('assignPlayerToFaction', () => {
    it('should assign a player to a faction', async () => {
      const playerId = 'player1';
      const factionId = 'forestElves';

      const result = await factionManager.assignPlayerToFaction(playerId, factionId);
      
      expect(result.status).toBe('player_assigned');
      
      const playerFaction = await factionManager.getPlayerFaction(playerId);
      expect(playerFaction.factionId).toBe(factionId);
    });

    it('should throw an error if faction does not exist', async () => {
      const playerId = 'player1';
      const factionId = 'nonExistentFaction';

      await expect(factionManager.assignPlayerToFaction(playerId, factionId))
        .rejects
        .toThrow('Faction nonExistentFaction does not exist');
    });
  });

  describe('getFactionBalance', () => {
    it('should return current faction balance', async () => {
      const balance = await factionManager.getFactionBalance();
      
      expect(balance.factions).toHaveLength(3);
      expect(balance.factions[0]).toHaveProperty('factionId');
      expect(balance.factions[0]).toHaveProperty('factionName');
      expect(balance.factions[0]).toHaveProperty('power');
      expect(balance.factions[0]).toHaveProperty('influence');
    });
  });

  describe('updateFactionStatus', () => {
    it('should update faction status with power and influence changes', async () => {
      const factionId = 'forestElves';
      const statusData = {
        powerChange: 10,
        influenceChange: -5
      };

      const result = await factionManager.updateFactionStatus(factionId, statusData);
      
      expect(result.status).toBe('updated');
      
      const balance = await factionManager.getFactionBalance();
      const forestElves = balance.factions.find(f => f.factionId === factionId);
      expect(forestElves.power).toBe(110);
      expect(forestElves.influence).toBe(95);
    });

    it('should throw an error if faction does not exist', async () => {
      const factionId = 'nonExistentFaction';
      const statusData = {
        powerChange: 10
      };

      await expect(factionManager.updateFactionStatus(factionId, statusData))
        .rejects
        .toThrow('Faction nonExistentFaction does not exist');
    });
  });

  describe('Event System', () => {
    it('should emit events when player is assigned to faction', async () => {
      const playerId = 'player1';
      const factionId = 'forestElves';
      
      let eventReceived = false;
      factionManager.addEventListener('faction.playerAssigned', (payload) => {
        eventReceived = true;
        expect(payload.playerId).toBe(playerId);
        expect(payload.factionId).toBe(factionId);
      });

      await factionManager.assignPlayerToFaction(playerId, factionId);
      
      expect(eventReceived).toBe(true);
    });
  });
});