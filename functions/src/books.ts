import * as functions from 'firebase-functions';
import { adminApp } from './adminApp';
import { checkOrGetDefaultVisibility } from './utils';

const firebaseTools = require('firebase-tools');
const firestore = adminApp.firestore();

/**
 * Add illustrations to an existing book.
 */
export const addIllustrations = functions
  .region('europe-west3')
  .https
  .onCall(async (params: UpdateBookIllustrationsParams, context) => {
    const userAuth = context.auth;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated', 
        `The function must be called from an authenticated user.`,
      );
    }

    const { bookId, illustrationsIds } = params;

    if (typeof bookId !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with a valid [id] parameter
         which is the book's id to update.`,
      );
    }

    if (!Array.isArray(illustrationsIds) || illustrationsIds.length === 0) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with a valid [illustrationsIds] parameter
         which is an array of illustrations' ids to add.`,
      );
    }

    const minimalIllustrations = await createBookIllustrations(illustrationsIds);

    const bookSnap = await firestore
      .collection('books')
      .doc(bookId)
      .get();

    const bookData = bookSnap.data();
    
    if (!bookSnap.exists || !bookData) {
      throw new functions.https.HttpsError(
        'not-found', 
        `The book to update doesn't exist anymore.`,
      );
    }

    if (bookData.user.id !== userAuth.uid) {
      throw new functions.https.HttpsError(
        'permission-denied',
        `You don't have the permission to update this book.`,
      )
    }

    const bookIllustrations: BookIllustration[] = bookData.illustrations;
    const newBookIllustrations = bookIllustrations.concat(minimalIllustrations);

    await bookSnap.ref.update({
      illustrations: newBookIllustrations,
    });

    return {
      items: illustrationsIds,
      successCount: illustrationsIds.length,
      hasErrors: false,
    };
  });

/**
 * Create a book document in Firestore.
 */
export const createOne = functions
  .region('europe-west3')
  .https
  .onCall(async (params: CreateBookParams, context) => {
    const userAuth = context.auth;
    const { name, illustrationsIds, visibility } = params;
    let { description } = params;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    if (typeof name !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The function must be called with a valid [name] parameter 
        which is the illustration's name.`,
      );
    }

    description = typeof description === 'string' ? description : '';

    const bookIllustrations = await createBookIllustrations(illustrationsIds);

    const addedBook = await firestore
      .collection('books')
      .add({
        createdAt: adminApp.firestore.FieldValue.serverTimestamp(),
        description,
        illustrations: bookIllustrations,
        layout: 'grid',
        layoutMobile: 'grid',
        layoutOrientation: 'vertical',
        layoutOrientationMobile: 'vertical',
        matrice: [],
        name,
        updatedAt: adminApp.firestore.FieldValue.serverTimestamp(),
        urls: {
          cover: '',
          icon: '',
        },
        user: {
          id: userAuth.uid,
        },
        visibility: checkOrGetDefaultVisibility(visibility),
      });

    return {
      id: addedBook.id,
      success: true,
    };
  });

/**
 * Delete a book document from Firestore.
 */
export const deleteOne = functions
  .region('europe-west3')
  .https
  .onCall(async (params: DeleteBookParams, context) => {
    const userAuth = context.auth;
    const { bookId } = params;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    if (typeof bookId !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The function must be called with a valid [bookId] argument
         which is the illustration's id to delete.`,
      );
    }

    const bookSnap = await firestore
      .collection('books')
      .doc(bookId)
      .get();

    const bookData = bookSnap.data();

    if (!bookSnap.exists || !bookData) {
      throw new functions.https.HttpsError(
        'permission-denied',
        `You don't have the permission to delete this book.`,
      )
    }

    await firebaseTools.firestore
      .delete(bookSnap.ref.path, {
        project: process.env.GCLOUD_PROJECT,
        recursive: true,
        yes: true,
      });

    return {
      bookId,
      success: true,
    };
  });

/**
 * Delete multiple books documents from Firestore.
 */
export const deleteMany = functions
  .region('europe-west3')
  .https
  .onCall(async (params: DeleteBooksParams, context) => {
    const userAuth = context.auth;
    const { bookIds } = params;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    if (!Array.isArray(bookIds) || bookIds.length === 0) {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `The function must be called with a valid [bookIds] argument 
        which is an array of illustrations' ids to delete.`,
      );
    }

    /** How many operations succeeded. */
    let successCount = 0;
    const itemsProcessed = [];

    for await (const bookId of bookIds) {
      try { // Some deletion may fail.
        const bookSnap = await firestore
          .collection('books')
          .doc(bookId)
          .get();

        const bookData = bookSnap.data();
        let errorMessage = `This book doesn't exist anymore.`;

        if (!bookSnap.exists || !bookData) {
          itemsProcessed.push({
            bookId,
            success: false,
            errorMessage,
          });

          throw new functions.https.HttpsError(
            'not-found',
            errorMessage,
          );
        }

        if (bookData.user.id !== userAuth.uid) {
          errorMessage = `You don't have the permission 
            to delete the book [${bookId}].`;

          itemsProcessed.push({
            bookId,
            success: false,
            errorMessage,
          });

          throw new functions.https.HttpsError(
            'permission-denied',
            errorMessage,
          );
        }

        await firebaseTools.firestore
          .delete(bookSnap.ref.path, {
            project: process.env.GCLOUD_PROJECT,
            recursive: true,
            yes: true,
          });

        itemsProcessed.push({
          bookId,
          success: true,
        });

        successCount++;

      } catch (error) {
        console.error(`Error while deleting book [${bookId}]`);
        console.error(error);
      }
    }

    return {
      items: itemsProcessed,
      successCount,
      hasErrors: successCount === bookIds.length,
    };
  });

/**
 * Delete illustrations from an existing book.
 */
export const removeIllustrations = functions
  .region('europe-west3')
  .https
  .onCall(async (params: UpdateBookIllustrationsParams, context) => {
    const userAuth = context.auth;
    const { bookId, illustrationsIds } = params;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    if (typeof bookId !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with a valid [bookId] (string) parameter
         which is the book to update.`,
      );
    }

    if (!Array.isArray(illustrationsIds) || illustrationsIds.length === 0) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with a valid [illustrationsIds] parameter
         which is the array of (string) illustrations to remove from the book.`,
      );
    }

    const bookSnap = await firestore
      .collection('books')
      .doc(bookId)
      .get();
      
    const bookData = bookSnap.data();
    
    if (!bookSnap.exists || !bookData){
      throw new functions.https.HttpsError(
        'not-found', 
        `The book to update doesn't exist anymore.`,
      );
    }
    
    if (bookData.user.id !== userAuth.uid){
      throw new functions.https.HttpsError(
        'permission-denied', 
        `You don't have the permission to update this book.`,
      );
    }

    const bookIllustrations: BookIllustration[] = bookData.illustrations;
    const newBookIllustrations = bookIllustrations
      .filter(illus => !illustrationsIds.includes(illus.id));

    await bookSnap.ref.update({
      illustrations: newBookIllustrations,
    });

    return {
      items: illustrationsIds,
      successCount: illustrationsIds.length,
      hasErrors: false,
    };
  });

/**
 * Update book's properties.
 */
export const updateMetadata = functions
  .region('europe-west3')
  .https
  .onCall(async (params: UpdateBookPropertiesParams, context) => {
    const userAuth = context.auth;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    checkUpdateBookPropsParam(params);

    const { 
      description, 
      bookId, 
      layout, 
      layoutMobile, 
      layoutOrientation, 
      layoutOrientationMobile, 
      name, 
      urls, 
      visibility, 
    } = params;

    const bookSnap = await firestore
      .collection('books')
      .doc(bookId)
      .get();

    const bookData = bookSnap.data();

    if (!bookSnap.exists || !bookData) {
      throw new functions.https.HttpsError(
        'not-found',
        `The book [${bookId}] doesn't exist anymore.`,
      )
    }

    if (bookData.user.id !== userAuth.uid) {
      throw new functions.https.HttpsError(
        'permission-denied',
        `You don't have the permission to update this book.`,
      )
    }

    await bookSnap.ref.update({
      description,
      layout,
      layoutMobile,
      layoutOrientation,
      layoutOrientationMobile,
      name,
      urls,
      visibility,
    });

    return {
      bookId,
      success: true,
    };
  });

/**
 * Update illustrations' position in an existing book.
 * For all [layout] except {extendedGrid} with the [matrice] property.
 */
export const updateIllusPosition = functions
  .region('europe-west3')
  .https
  .onCall(async (params: UpdateIllusPositionParams, context) => {
    const userAuth = context.auth;

    const { 
      bookId,
      beforePosition,
      afterPosition,
      illustrationId,
    } = params;

    if (!userAuth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        `The function must be called from an authenticated user.`,
      );
    }

    if (typeof bookId !== 'string' || typeof illustrationId !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with a valid [bookId] & [illustrationId] parameters
         which are respectively the book's id & the illustration's id to update.`,
      );
    }

    if (typeof beforePosition !== 'number' || typeof afterPosition !== 'number') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `The function must be called with a valid 
        [beforePosition] & [afterPosition] parameters 
        which are respectively the position before and the position after the update.`,
      );
    }

    const bookSnap = await firestore
      .collection('books')
      .doc(bookId)
      .get();
      
    const bookData = bookSnap.data();

    if (!bookSnap.exists || !bookData){
      throw new functions.https.HttpsError(
        'not-found', 
        `The book to update doesn't exist anymore.`,
      );
    }

    if (bookData.user.id !== userAuth.uid) {
      throw new functions.https.HttpsError(
        'permission-denied', 
        `You don't have the permission to delete update book.`,
      );
    }

    const illustrations: BookIllustration[] = bookData.illustrations;
    const deletedItems = illustrations.splice(beforePosition, 1);

    if (!deletedItems || deletedItems.length === 0) {
      throw new functions.https.HttpsError(
        'invalid-argument', 
        `Invalid [beforePosition] argument. The number specified may be out of range.`,
      );
    }

    const illusToMove = deletedItems[0];
    illustrations.splice(afterPosition, 0, illusToMove);

    await bookSnap.ref.update({
      illustrations,
    });

    return {
      illustrationId,
      success: true,
    };
  });

// ----------------
// Helper functions
// ----------------

/**
 * Check new book's properties types and values.
 * @param params - Updated book's properties.
 */
function checkUpdateBookPropsParam(params: UpdateBookPropertiesParams) {
  if (!params) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `The function must be called with a valid [id] & [illustrationsIds] parameters 
      which are respectively the book's id and an illustrations' ids array.`,
    );
  }

  const {
    description,
    layout,
    layoutMobile,
    layoutOrientation,
    layoutOrientationMobile,
    name,
    visibility,
  } = params;

  if (typeof description !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `The function must have a [description] parameter
       which is the updated Book's description.`,
    )
  }

  if (typeof layout !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `The function must have a [layout] parameter which is the updated Book's layout.`,
    );
  }

  const allowedLayouts = [
    'adaptativeGrid',
    'customExtendedGrid',
    'customGrid',
    'customList',
    'grid',
    'horizontalList',
    'horizontalListWide',
    'largeGrid',
    'smallGrid',
    'twoPagesBook',
    'verticalList',
    'verticalListWide',
  ];

  if (!allowedLayouts.includes(layout)) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `Allow values for [layout] parameter are: adaptativeGrid, 
      customExtendedGrid,customGrid, customList, grid, horizontalList, 
      horizontalListWide, largeGrid, smallGrid, twoPagesBook, 
      verticalList, verticalListWide.`,
    );
  }

  if (typeof layoutMobile !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `The function must have a [layoutMobile] parameter 
      which is the updated Book's layout on small screens.`,
    )
  }

  if (!allowedLayouts.includes(layoutMobile)) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `Allow values for [layout] parameter are: adaptativeGrid, customExtendedGrid,
       customGrid, customList, grid, horizontalList, horizontalListWide,
       largeGrid, smallGrid, twoPagesBook, verticalList, verticalListWide.`,
    );
  }

  const allowedLayoutOrientations = ['both', 'horizontal', 'vertical'];

  if (typeof layoutOrientation !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `The function must have a [layoutOrientation] parameter
       which is the updated Book's layout orientation.`,
    )
  }

  if (!allowedLayoutOrientations.includes(layoutOrientation)) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `Allow values for [layoutOrientation] parameter are:
       both, horizontal, vertical,`,
    );
  }

  if (typeof layoutOrientationMobile !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `The function must have a [layoutOrientationMbile] parameter
       which is the updated Book's layout orientation on small screens.`,
    )
  }

  if (!allowedLayoutOrientations.includes(layoutOrientationMobile)) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `Allow values for [layoutOrientationMobile] parameter are:
       both, horizontal, vertical.`,
    );
  }

  if (typeof name !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `The function must have a [name] parameter
       which is the updated Book's name.`,
    )
  }

  if (typeof visibility !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `The function must have a [visibility] parameter
       which is the updated Book's visibility.`,
    )
  }

  const allowedVisibility = ['acl', 'challenge', 'contest', 'gallery', 'private', 'public'];

  if (!allowedVisibility.includes(visibility)) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `Allow values for [visibility] parameter are:
       'acl', 'challenge', 'contest', 'gallery', 'private', 'public'.`,
    );
  }
}

/**
 * Create an array of simple illustrations objects.
 * @param ids - Illustrations' ids to create.
 */
async function createBookIllustrations(ids: string[]) {
  if (!ids || !Array.isArray(ids) || ids.length === 0) {
    return [];
  }

  const arrayResult: BookIllustration[] = [];

  for (const id of ids) {
    arrayResult.push({
      id,
      vScaleFactor: {
        height: 1,
        width: 1,
        mobileHeight: 1,
        mobileWidth: 1,
      },
    });
  }

  return arrayResult;
}
