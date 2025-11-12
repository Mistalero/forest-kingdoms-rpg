// P2P Adapter for Forest Kingdoms RPG
// This module integrates the decentralized P2P component with the game's networking layer

// Import the P2P components
import IdentityLayer from '../../../p2p/implementations/javascript/src/index.js';
import StateSyncLayer from '../../../p2p/implementations/javascript/src/StateSyncLayer.js';

class P2PAdapter {
  constructor() {
    // Initialize the identity layer
    this.identityLayer = new IdentityLayer();
    
    // Generate Nostr keys for this node
    const keys = this.identityLayer.generateNostrKeys();
    console.log('Generated Nostr keys:', keys);
    
    // Create DID document for this node
    this.didDocument = this.identityLayer.createDIDDocument('forest-kingdoms-rpg-node');
    console.log('Created DID document:', this.didDocument);
    
    // Initialize the state sync layer
    this.stateSyncLayer = new StateSyncLayer();
    
    // Store for game state CRDTs
    this.gameStateCRDTs = new Map();
  }

  // Create a new CRDT for game state synchronization
  createGameStateCRDT(id, type, initialValue = null) {
    try {
      const crdt = this.stateSyncLayer.createCRDT(id, type, initialValue);
      this.gameStateCRDTs.set(id, crdt);
      return crdt;
    } catch (error) {
      console.error(`Failed to create CRDT ${id}:`, error);
      throw error;
    }
  }

  // Get a CRDT by ID
  getGameStateCRDT(id) {
    return this.gameStateCRDTs.get(id);
  }

  // Update a CRDT with an operation
  updateGameStateCRDT(id, operation) {
    try {
      const crdt = this.stateSyncLayer.updateCRDT(id, operation);
      return crdt;
    } catch (error) {
      console.error(`Failed to update CRDT ${id}:`, error);
      throw error;
    }
  }

  // Merge with another CRDT
  mergeGameStateCRDT(id, otherCRDT) {
    try {
      const crdt = this.stateSyncLayer.mergeCRDT(id, otherCRDT);
      return crdt;
    } catch (error) {
      console.error(`Failed to merge CRDT ${id}:`, error);
      throw error;
    }
  }

  // Serialize all game state CRDTs to JSON
  serializeGameState() {
    return this.stateSyncLayer.serializeState();
  }

  // Deserialize game state from JSON
  deserializeGameState(state) {
    try {
      this.stateSyncLayer.deserializeState(state);
    } catch (error) {
      console.error('Failed to deserialize game state:', error);
      throw error;
    }
  }

  // Get the node ID (DID)
  getNodeId() {
    return this.stateSyncLayer.getNodeId();
  }

  // Get the DID document
  getDIDDocument() {
    return this.stateSyncLayer.getDIDDocument();
  }

  // Resolve a DID
  async resolveDID(did) {
    try {
      const didDocument = await this.stateSyncLayer.resolveDID(did);
      return didDocument;
    } catch (error) {
      console.error(`Failed to resolve DID ${did}:`, error);
      throw error;
    }
  }
}

// Export P2PAdapter
export default P2PAdapter;