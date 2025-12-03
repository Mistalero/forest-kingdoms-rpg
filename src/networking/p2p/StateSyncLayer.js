// State Synchronization Layer Implementation for Forest Kingdoms RPG
// This module implements CRDT-based state synchronization for the P2P network

class StateSyncLayer {
  constructor() {
    this.crdts = new Map();
    this.nodeId = this._generateNodeId();
    this.didDocument = null;
  }

  // Set the DID document for this node
  setDIDDocument(didDocument) {
    this.didDocument = didDocument;
  }

  // Get the node ID (DID)
  getNodeId() {
    if (this.didDocument) {
      return this.didDocument.id;
    }
    return this.nodeId;
  }

  // Get the DID document
  getDIDDocument() {
    return this.didDocument;
  }

  // Resolve a DID
  async resolveDID(did) {
    // In a real implementation, this would query the appropriate network
    // For now, we'll just return a mock document
    return {
      id: did,
      resolved: true
    };
  }

  // Create a new CRDT
  createCRDT(id, type, initialValue = null) {
    let crdt;
    
    switch (type) {
      case 'LWWRegister':
        crdt = new LWWRegister(id, initialValue, this.getNodeId());
        break;
      case 'ORSet':
        crdt = new ORSet(id, initialValue, this.getNodeId());
        break;
      default:
        throw new Error(`Unsupported CRDT type: ${type}`);
    }
    
    this.crdts.set(id, crdt);
    return crdt;
  }

  // Update a CRDT with an operation
  updateCRDT(id, operation) {
    const crdt = this.crdts.get(id);
    
    if (!crdt) {
      throw new Error(`CRDT with id ${id} not found`);
    }
    
    crdt.applyOperation(operation);
    return crdt;
  }

  // Merge with another CRDT
  mergeCRDT(id, otherCRDT) {
    const localCRDT = this.crdts.get(id);
    
    if (!localCRDT) {
      // If we don't have this CRDT locally, create it
      this.crdts.set(id, otherCRDT);
      return otherCRDT;
    }
    
    // Merge the CRDTs
    localCRDT.merge(otherCRDT);
    return localCRDT;
  }

  // Serialize all CRDTs to JSON
  serializeState() {
    const state = {};
    
    for (const [id, crdt] of this.crdts) {
      state[id] = crdt.serialize();
    }
    
    return JSON.stringify(state);
  }

  // Deserialize CRDTs from JSON
  deserializeState(state) {
    const stateObj = JSON.parse(state);
    
    for (const id in stateObj) {
      const crdtData = stateObj[id];
      let crdt;
      
      switch (crdtData.type) {
        case 'LWWRegister':
          crdt = LWWRegister.deserialize(crdtData);
          break;
        case 'ORSet':
          crdt = ORSet.deserialize(crdtData);
          break;
        default:
          console.warn(`Unknown CRDT type: ${crdtData.type}`);
          continue;
      }
      
      this.crdts.set(id, crdt);
    }
  }

  // Helper methods
  _generateNodeId() {
    // Generate a mock node ID
    return 'node-' + Array.from({length: 8}, () => Math.floor(Math.random() * 16).toString(16)).join('');
  }
}

// Last-Write-Wins Register CRDT
class LWWRegister {
  constructor(id, value, nodeId) {
    this.id = id;
    this.type = 'LWWRegister';
    this.value = value;
    this.timestamp = Date.now();
    this.nodeId = nodeId;
  }

  // Set a new value
  set(value, nodeId) {
    this.value = value;
    this.timestamp = Date.now();
    this.nodeId = nodeId;
  }

  // Get the current value
  get() {
    return this.value;
  }

  // Merge with another LWWRegister
  merge(other) {
    if (other.timestamp > this.timestamp || 
        (other.timestamp === this.timestamp && other.nodeId > this.nodeId)) {
      this.value = other.value;
      this.timestamp = other.timestamp;
      this.nodeId = other.nodeId;
    }
  }

  // Apply an operation
  applyOperation(operation) {
    if (operation.type === 'set') {
      this.set(operation.value, operation.nodeId);
    }
  }

  // Serialize to JSON
  serialize() {
    return {
      id: this.id,
      type: this.type,
      value: this.value,
      timestamp: this.timestamp,
      nodeId: this.nodeId
    };
  }

  // Deserialize from JSON
  static deserialize(data) {
    const register = new LWWRegister(data.id, data.value, data.nodeId);
    register.timestamp = data.timestamp;
    return register;
  }
}

// Observed-Remove Set CRDT
class ORSet {
  constructor(id, initialValues = [], nodeId) {
    this.id = id;
    this.type = 'ORSet';
    this.elements = new Map();
    
    // Add initial values
    if (Array.isArray(initialValues)) {
      for (const element of initialValues) {
        this.add(element, nodeId);
      }
    }
  }

  // Add an element to the set
  add(element, nodeId) {
    if (!this.elements.has(element)) {
      this.elements.set(element, new Set());
    }
    
    // Add the tag (nodeId + timestamp) to the element's tags
    const tag = `${nodeId}-${Date.now()}`;
    this.elements.get(element).add(tag);
  }

  // Remove an element from the set
  remove(element, nodeId) {
    if (this.elements.has(element)) {
      // In a real implementation, we would remove all tags
      // For simplicity, we'll just clear all tags
      this.elements.delete(element);
    }
  }

  // Check if an element is in the set
  contains(element) {
    return this.elements.has(element);
  }

  // Get all elements in the set
  getElements() {
    return Array.from(this.elements.keys());
  }

  // Merge with another ORSet
  merge(other) {
    for (const [element, tags] of other.elements) {
      if (!this.elements.has(element)) {
        this.elements.set(element, new Set(tags));
      } else {
        // Merge tags
        for (const tag of tags) {
          this.elements.get(element).add(tag);
        }
      }
    }
  }

  // Apply an operation
  applyOperation(operation) {
    if (operation.type === 'add') {
      this.add(operation.element, operation.nodeId);
    } else if (operation.type === 'remove') {
      this.remove(operation.element, operation.nodeId);
    }
  }

  // Serialize to JSON
  serialize() {
    const elements = {};
    
    for (const [element, tags] of this.elements) {
      elements[element] = Array.from(tags);
    }
    
    return {
      id: this.id,
      type: this.type,
      elements: elements
    };
  }

  // Deserialize from JSON
  static deserialize(data) {
    const set = new ORSet(data.id, [], '');
    
    for (const element in data.elements) {
      set.elements.set(element, new Set(data.elements[element]));
    }
    
    return set;
  }
}

// Export StateSyncLayer and CRDT classes
export default StateSyncLayer;
export { LWWRegister, ORSet };