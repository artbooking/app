import * as functions from 'firebase-functions';
import algolia from 'algoliasearch';
import deepEqual = require('deep-equal');
import { cloudRegions } from './utils';

const env = functions.config();

const client = algolia(env.algolia.appid, env.algolia.apikey);
const illustrationsIndex = client.initIndex('illustrations');
const licensesIndex = client.initIndex('licenses');
const stylesIndex = client.initIndex('styles');
const usersIndex = client.initIndex('users');

// ----------------
// Art styles index
// ----------------
/**
 * Update styles index on create document.
 */
export const onIndexStyle = functions
  .region(cloudRegions.eu)
  .firestore
  .document('styles/{styleId}')
  .onCreate(async (snapshot) => {
    const data = snapshot.data();
    const objectID = snapshot.id;

    return stylesIndex.saveObject({
      objectID,
      ...data,
    })
  });

/**
 * Update styles index on update document.
 */
  export const onReIndexStyle = functions
  .region(cloudRegions.eu)
  .firestore
  .document('styles/{styleId}')
  .onUpdate(async (snapshot) => {
    const data = snapshot.after.data();
    const objectID = snapshot.after.id;

    return stylesIndex.saveObject({
      objectID,
      ...data,
    })
  });

/**
 * Update styles index on delete document.
 */
  export const onUnIndexStyle = functions
  .region(cloudRegions.eu)
  .firestore
  .document('styles/{styleId}')
  .onDelete(async (snapshot) => {
    const objectID = snapshot.id;
    return stylesIndex.deleteObject(objectID);
  });

// -------------------
// Illustrations index
// -------------------
export const onIndexIllustration = functions
  .region(cloudRegions.eu)
  .firestore
  .document('illustrations/{illustrationId}')
  .onCreate(async (snapshot) => {
    const data = snapshot.data();
    const objectID = snapshot.id;

    // Do not index private iillustrations.
    if (data.visibility !== 'public') {
      return;
    }

    return illustrationsIndex.saveObject({
      objectID,
      ...data,
    });
  });

export const onReIndexIllustration = functions
  .region(cloudRegions.eu)
  .firestore
  .document('illustrations/{illustrationId}')
  .onUpdate(async (snapshot) => {
    const data = snapshot.after.data();
    const objectID = snapshot.after.id;

    // Remove image from index if not public anymore.
    if (data.visibility !== 'public') {
      return illustrationsIndex.deleteObject(objectID);
    }

    return illustrationsIndex.saveObject({
      objectID,
      ...data,
    })
  });

export const onUnIndexIllustration = functions
  .region(cloudRegions.eu)
  .firestore
  .document('illustrations/{illustrationId}')
  .onDelete(async (snapshot) => {
    const data = snapshot.data();
    const objectID = snapshot.id;

    // This image was not indexed.
    if (data.visibility !== 'public') {
      return;
    }

    return illustrationsIndex.deleteObject(objectID);
  });

// ----------------
// Licenses index
// ----------------
/**
 * Update licenses index on create document.
 */
export const onIndexLicense = functions
  .region(cloudRegions.eu)
  .firestore
  .document('licenses/{licenseId}')
  .onCreate(async (snapshot) => {
    const data = snapshot.data();
    const objectID = snapshot.id;

    return licensesIndex.saveObject({
      objectID,
      ...data,
    })
  });

/**
 * Update licenses index on update document.
 */
export const onReIndexLicense = functions
  .region(cloudRegions.eu)
  .firestore
  .document('licenses/{licenseId}')
  .onUpdate(async (snapshot) => {
    const data = snapshot.after.data();
    const objectID = snapshot.after.id;

    return licensesIndex.saveObject({
      objectID,
      ...data,
    })
  });

/**
 * Update licenses index on delete document.
 */
export const onUnIndexLicense = functions
  .region(cloudRegions.eu)
  .firestore
  .document('licenses/{licenseId}')
  .onDelete(async (snapshot) => {
    const objectID = snapshot.id;
    return licensesIndex.deleteObject(objectID);
  });

// -----------
// Users index
// -----------
export const onIndexUser = functions
  .region(cloudRegions.eu)
  .firestore
  .document('users/{userId}')
  .onCreate(async (snapshot) => {
    const data = snapshot.data();
    const objectID = snapshot.id;

    return usersIndex.saveObject({
      objectID,
      lang: data.lang,
      name: data.name,
      nameLowerCase: data.nameLowerCase,
      pricing: data.pricing,
      urls: data.urls,
    });
  });

export const onReIndexUser = functions
  .region(cloudRegions.eu)
  .firestore
  .document('users/{userId}')
  .onUpdate(async (snapshot) => {
    const beforeData = snapshot.before.data();
    const afterData = snapshot.after.data();
    const objectID = snapshot.after.id;

    if (!indexedPropChanged(beforeData, afterData)) {
      return;
    }

    return usersIndex.saveObject({
      objectID,
      lang: afterData.lang,
      name: afterData.name,
      nameLowerCase: afterData.nameLowerCase,
      pricing: afterData.pricing,
      urls: afterData.urls,
    });
  });

export const onUnIndexUser = functions
  .region(cloudRegions.eu)
  .firestore
  .document('users/{userId}')
  .onDelete(async (snapshot) => {
    const objectID = snapshot.id;
    return usersIndex.deleteObject(objectID);
  });

// -------
// Helpers
// -------

/**
 * Return true if indexed (search) properties was updated.
 * @param beforeData Firestore data before doc update.
 * @param afterData Firestore data after doc update.
 */
function indexedPropChanged(
  beforeData: FirebaseFirestore.DocumentData,
  afterData: FirebaseFirestore.DocumentData,
): boolean {

  if (beforeData.lang !== afterData.lang) {
    return true;
  }

  if (beforeData.name !== afterData.name) {
    return true;
  }

  if (beforeData.nameLowerCase !== afterData.nameLowerCase) {
    return true;
  }

  if (beforeData.pricing !== afterData.pricing) {
    return true;
  }

  // Urls
  const beforeUrls = beforeData.urls;
  const afterUrls = afterData.urls;

  if (!deepEqual(beforeUrls, afterUrls, { strict: true })) {
    return true;
  }

  return false;
}
