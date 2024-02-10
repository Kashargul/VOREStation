/**
 * Browser-agnostic abstraction of key-value web storage.
 *
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

export const IMPL_MEMORY = 0;
export const IMPL_LOCAL_STORAGE = 1;
export const IMPL_INDEXED_DB = 2;

const INDEXED_DB_VERSION = 1;
const INDEXED_DB_NAME = 'virgo';
const INDEXED_DB_STORE_NAME = 'storage-v1';
const INDEXED_DB_ARCHIVE_NAME = 'archive-v1';
const INDEXED_DB_ARCHIVE_SIZE_KEY = 'archive-v1-size';

const READ_ONLY = 'readonly';
const READ_WRITE = 'readwrite';

const testGeneric = (testFn) => () => {
  try {
    return Boolean(testFn());
  } catch {
    return false;
  }
};

// Localstorage can sometimes throw an error, even if DOM storage is not
// disabled in IE11 settings.
// See: https://superuser.com/questions/1080011
// prettier-ignore
const testLocalStorage = testGeneric(() => (
  window.localStorage && window.localStorage.getItem
));

// prettier-ignore
const testIndexedDb = testGeneric(() => (
  (window.indexedDB || window.msIndexedDB)
  && (window.IDBTransaction || window.msIDBTransaction)
));

class MemoryBackend {
  constructor() {
    this.impl = IMPL_MEMORY;
    this.store = {};
  }

  get(key) {
    return this.store[key];
  }

  set(key, value) {
    this.store[key] = value;
  }

  remove(key) {
    this.store[key] = undefined;
  }

  clear() {
    this.store = {};
  }
}

class LocalStorageBackend {
  constructor() {
    this.impl = IMPL_LOCAL_STORAGE;
  }

  get(key) {
    const value = localStorage.getItem(key);
    if (typeof value === 'string') {
      return JSON.parse(value);
    }
  }

  set(key, value) {
    localStorage.setItem(key, JSON.stringify(value));
  }

  remove(key) {
    localStorage.removeItem(key);
  }

  clear() {
    localStorage.clear();
  }
}

class IndexedDbBackend {
  constructor() {
    this.impl = IMPL_INDEXED_DB;
    /** @type {Promise<IDBDatabase>} */
    this.dbPromise = new Promise((resolve, reject) => {
      const indexedDB = window.indexedDB || window.msIndexedDB;
      const req = indexedDB.open(INDEXED_DB_NAME, INDEXED_DB_VERSION);
      req.onupgradeneeded = () => {
        try {
          req.result.createObjectStore(INDEXED_DB_STORE_NAME);
        } catch (err) {
          reject(new Error('Failed to upgrade IDB: ' + req.error));
        }
      };
      req.onsuccess = () => resolve(req.result);
      req.onerror = () => {
        reject(new Error('Failed to open IDB: ' + req.error));
      };
    });
  }

  getStore(mode) {
    // prettier-ignore
    return this.dbPromise.then((db) => db
      .transaction(INDEXED_DB_STORE_NAME, mode)
      .objectStore(INDEXED_DB_STORE_NAME));
  }

  getArchive(mode) {
    // prettier-ignore
    return this.dbPromise.then((db) => db
    .transaction(INDEXED_DB_ARCHIVE_NAME, mode)
    .objectStore(INDEXED_DB_ARCHIVE_NAME));
  }

  async get(key) {
    const store = await this.getStore(READ_ONLY);
    return new Promise((resolve, reject) => {
      const req = store.get(key);
      req.onsuccess = () => resolve(req.result);
      req.onerror = () => reject(req.error);
    });
  }

  async set(key, value) {
    // The reason we don't _save_ null is because IE 10 does
    // not support saving the `null` type in IndexedDB. How
    // ironic, given the bug below!
    // See: https://github.com/mozilla/localForage/issues/161
    if (value === null) {
      value = undefined;
    }
    // NOTE: We deliberately make this operation transactionless
    const store = await this.getStore(READ_WRITE);
    store.put(value, key);
  }

  async remove(key) {
    // NOTE: We deliberately make this operation transactionless
    const store = await this.getStore(READ_WRITE);
    store.delete(key);
  }

  async clear() {
    // NOTE: We deliberately make this operation transactionless
    const store = await this.getStore(READ_WRITE);
    store.clear();
  }

  /**
   * @param objectStore {IDBObjectStore}
   * @return {Promise<Number>}
   */
  async getArchiveLength(objectStore) {
    return new Promise((resolve, reject) => {
      const req = objectStore.get(INDEXED_DB_ARCHIVE_SIZE_KEY);
      req.onsuccess = () => resolve(req.result);
      req.onerror = () => resolve(0);
    });
  }

  /**
   * @param objectStore {IDBObjectStore}
   * @param newLength {Number}
   */
  setArchiveLength(objectStore, newLength) {
    objectStore.put(newLength, INDEXED_DB_ARCHIVE_SIZE_KEY);
  }

  /**
   * @param messages {Array<Object>}
   * @return {Promise<Number>}
   */
  async setArchive(messages) {
    const archive = await this.getArchive(READ_WRITE);
    const numMessages = messages.length;
    const numArchiveMessages = await this.getArchiveLength(archive);
    const difference = numMessages - numArchiveMessages;
    if (!isNaN(difference) && difference > 0) {
      const sliceEnd = numMessages - difference;
      const numAdditions = messages.length - sliceEnd;
      // const messageSlice = messages.slice(sliceEnd);
      for (let i = sliceEnd; i < messages.length; i++) {
        archivePut(archive, i, messages[i]);
      }
      // update the archive size
      setArchiveLength(archive, numArchiveMessages + numAdditions);
    }
  }

  /**
   * @param objectStore {IDBObjectStore}
   */
  archivePut(objectStore, key, value) {
    // TODO: check that it doesn't fail
    objectStore.put(value, key);
  }

  /** returns an array of messages
   * @return {Promise<Array>}
   */
  async getArchivedMessages() {
    const archive = await this.getArchive(READ_WRITE);
    const numArchiveMessages = await this.getArchiveLength(archive);
    // let ret = [];

    return new Promise((resolve, reject) => {
      const req = archive.getAll(
        IDBKeyRange.bound(0, numArchiveMessages, false, true),
      );
      req.onsuccess = () => resolve(req.result);
      req.onerror = () => reject(req.error);
    });
  }
}

/**
 * Web Storage Proxy object, which selects the best backend available
 * depending on the environment.
 */
class StorageProxy {
  constructor() {
    this.backendPromise = (async () => {
      if (testIndexedDb()) {
        try {
          const backend = new IndexedDbBackend();
          await backend.dbPromise;
          return backend;
        } catch {}
      }
      if (testLocalStorage()) {
        return new LocalStorageBackend();
      }
      return new MemoryBackend();
    })();
  }

  async get(key) {
    const backend = await this.backendPromise;
    return backend.get(key);
  }

  async set(key, value) {
    const backend = await this.backendPromise;
    return backend.set(key, value);
  }

  async remove(key) {
    const backend = await this.backendPromise;
    return backend.remove(key);
  }

  async clear() {
    const backend = await this.backendPromise;
    return backend.clear();
  }

  async getArchivedMessages() {
    const backend = await this.backendPromise;
    if (typeof backend !== IndexedDbBackend) return;
    return backend.getArchivedMessages();
  }

  /**
   * @param messages {Array<Object>}
   * @return {Promise<Number>}
   */
  async setArchive(messages) {
    const backend = await this.backendPromise;
    if (typeof backend !== IndexedDbBackend) return;
    backend.setArchive(messages);
  }
}

export const storage = new StorageProxy();
