enum BookLayout {
  /**
   * Display illustrations on a grid with a size adapted 
   * to the aspect ratio of each illustration's dimensions.
   * e.g. if an illustration has an original size of 2000x2000, 
   * it'll be displayed as a 300x300 item — 
   * if another one is 2000x3000, it'll be displayed as a 150x300 item.
   */
  adaptativeGrid = 'adaptativeGrid',

  /**
   * Display items on a grid with a custom size for each illustrations. 
   * They're 300x300 by default. With the [vScaleFactor] property, they can be larger or smaller. 
   * The grid can both be scrolled on the horizontal and vertical axis. 
   * This grid con contain a row and a column that exceed the screen's size. 
   * Items's position are stored in the [matrice] property.
   */
  customExtendedGrid = 'customExtendedGrid',

  /**
   * Display items on a grid with a custom size for each illustrations. 
   * They're 300x300 by default. With the [vScaleFactor] property, they can be larger or smaller. 
   * The grid can only be scrolled on the horizontal or vertical axis according to [layoutOrientation].
   */
  customGrid = 'customGrid',

  /**
   * Display items in a list with a custom size for each illustrations. 
   * They're 300x300 by default. With the [vScaleFactor] property, they can be larger or smaller.
   */
  customList = 'customList',

  /** Display illustrations on a grid of 300x300. */
  grid = 'grid',

  /** Display illustrations in a horizontal list of 300x300px. */
  horizontalList = 'horizontalList',

  /** Display illustrations in a horizontal list of 300px width, and 150px height. */
  horizontalListWide = 'horizontalListWide',

  /** Display illustrations on a grid of 600x600. */
  largeGrid = 'largeGrid',

  /** Display illustrations on a grid of 150x150. */
  smallGrid = 'smallGrid',
  
  /** Display two illustrations at a time on a screen. */
  twoPagesBook = 'twoPagesBook',
  
  /** Display illustrations in a list with item of 300x300 pixels. */
  verticalList = 'verticalList',
  
  /** Display illustrations on a grid of 300px width and 150px height. */
  verticalListWide = 'verticalListWide',
}

enum LayoutOrientation {
  both = 'both',
  horizontal = 'horizontal',
  vertical = 'vertical',
}

/** Control if other people can view this content. */
enum Visibility {
  /** Custom access control list based on users' roles. */
  acl = 'acl',

  /** Inherit the challenge's visibility. */
  challenge = 'challenge',

  /** Inherit the contest's visibility. */
  contest = 'contest',

  /** Inherit the gallery's visibility. */
  gallery = 'gallery',

  /** Only the owner can view this illustration. */
  private = 'private',

  /** Anyone with a link can view this illustration. */
  public = 'public',
}

interface CreateUserAccountParams {
  email: string;
  password: string;
  username: string;
}

interface CreateBookParams {
  description: string;
  illustrations: string[];
  name: string;
  visibility: Visibility;
}

interface CreateIllustrationParams {
  name: string;
  isUserAuthor: boolean;
  visibility: Visibility;
}

interface DataUpdateParams {
  beforeData: FirebaseFirestore.DocumentData;
  afterData: FirebaseFirestore.DocumentData;
  payload: any;
  docId: string;
}

interface DeleteAccountParams {
  idToken: string;
}


interface DeleteBookParams {
  /** Book's id. */
  id: string;
}

interface DeleteBooksParams {
  /** Book's id. */
  ids: string[];
}

interface DeleteIllustrationParams {
  /** Illustration's id. */
  id: string;
}

interface DeleteMultipleIllustrationsParams {
  /// Array of illustrations ids.
  ids: string[];
}

interface DeleteListParams {
  listId: string;
  idToken: string;
}

interface GenerateImageThumbsResult {
  dimensions: ImageDimensions;
  thumbnails: ThumbnailUrls;
}

interface ImageDimensions {
  height: number;
  width: number;
}
interface NotifFuncParams {
  userId: string;
  userData: any;
  notifSnapshot: FirebaseFirestore.QueryDocumentSnapshot;
}

interface SetUserAuthorParams {
  imageId: string;
}

interface BookIllustration {
  createdAt: any;
  id: string;
  updatedAt: any;
  vScaleFactor: {
    height: number;
    mobileHeight: number;
    mobileWidth: number;
    width: number;
  };
}

interface ThumbnailUrls {
  [key: string]: String,
  t360: String;
  t480: String;
  t720: String;
  t1080: String;
}

interface UpdateBookIllustrationsParams {
  /** Book's id. */
  bookId: string;

  /** illustrations' ids. */
  illustrationsIds: string[];
}

interface UpdateBookPropertiesParams {
  /** This book's id. */
  bookId: string;

  /** This book's description. */
  description: string;

  /** Defines content layout and presentation. */
  layout: BookLayout;
  
  /** Defines content layout and presentation for small screens. Same as layout. */
  layoutMobile: BookLayout;
  
  /** 
   * Defines layout scroll orientation. 
   * Will be used if [layout] value is {adaptativeGrid}, 
   * {customGrid}, {customList}, {grid}, {smallGrid}, {largeGrid}.
   */
  layoutOrientation: LayoutOrientation;

  /**
   * For small resolutions, defines layout scroll orientation. 
   * Will be used if [layout] value is {adaptativeGrid}, 
   * {customGrid}, {customList}, {grid}, {smallGrid}, {largeGrid}.
   */
  layoutOrientationMobile: LayoutOrientation;

  /** This book's name. */
  name: string;

  urls: {
    cover: string;
    icon: string;
  }

  visibility: Visibility;
}

interface UpdateEmailParams {
  newEmail: string;
  idToken: string;
}
interface UpdateIllusPositionParams {
  /** Illustration's position (int) before the update. */
  afterPosition: number;
  
  /** Illustration's position (int) after the update. */
  beforePosition: number;
  
  /** Book's id to update. */
  bookId: string;

  /** Illustration's id to re-order. */
  illustrationId: string;
}

interface UpdateImagePropsParams {
  /** Illustration's description. */
  description: string,
  
  /** Illustration's id. */
  id: string;
  
  /** Illustration's name. */
  name: string;
  
  /** Illustration's license. */
  license: string;
  
  /** Detailed text explaining more about this illustration. */
  summary: string;

  /** Image's visibility. */
  visibility: Visibility;
}

interface UpdateImageCategoriesParams {
  /** Image's categories. */
  categories: [string],
  
  /** Image's id. */
  id: string;
}

interface UpdateImageTopicsParams {
  /** Image's topics. */
  topics: [string],
  
  /** Image's id. */
  id: string;
}

interface UpdateUsernameParams {
  newUsername: string;
}
