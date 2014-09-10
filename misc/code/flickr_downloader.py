import urllib
import sys
import os

def search2_download_dir(search_string):
    # Make default directory corresponding to search
    default_download_root  = 'D:/data/downloads/'
    default_download_dname = 'FLICKR_'+search_string.replace(' ','_')+'/'
    default_download_dir   = download_root+dl_dir
    return default_download_dir

def main():
    import sys
    for argv in sys.argv:
        if argv == '--my-searches':
            my_searches()
        if argv == '--my-recover':
            my_recover()
        if argv == '--my-verify':
            my_verify()

def my_vars():
    sys.path.append(r'C:\Users\jon.crall\Dropbox\Code')
    import crall
    kwargs = {
        'api_key' : crall.flickr_api_key, 
        'secret'  : crall.flickr_api_secret }
    download_dir = r'D:\data\downloads\amur_leopards'
    search_string = 'amur leopards'
    return kwargs, download_dir, search_string

def my_verify():
    print "verifying"
    (kwargs, download_dir, search_string) = my_vars()
    baddies = verify_downloads(download_dir)
    delete_baddies(baddies)

def my_recover():
    print "recovering"
    (kwargs, download_dir, search_string) = my_vars()
    baddies = verify_downloads(download_dir)
    delete_baddies(baddies)
    url_list_fpath = os.path.join(download_dir,search_string+'_downloading_files.txt')
    url_list = eval(open(url_list_fpath,'r').read())
    flickr_download_url_list(url_list, download_dir)

def my_searches():
    (kwargs, download_dir, search_string) = my_vars()
    #
    download_dir = r'D:\data\downloads\amur_leopards'
    searches = ['amur leopards',
                'amur leopards in the wild']
    #
    for search_string in searches:
        flickr_download(search_string, download_dir, **kwargs)

def crall_search(search_string):
    sys.path.append(r'C:\Users\jon.crall\Dropbox\Code')
    import crall
    kwargs = {
        'api_key' : crall.flickr_api_key, 
        'secret'  : crall.flickr_api_secret }
    search_string = 'amur leopards'
    download_dir = search2_download_dir(search_string)
    flickr_download(search_string, download_dir, max_tries=100, **kwargs)


def flickr_download(search_string, download_dir, **kwargs):
    'Convinence function for user to download results of a search to a directory'
    url_list_fpath = os.path.join(download_dir,search_string+'_downloading_files.txt')
    if os.path.exists(url_list_fpath):
        raise Exception('You already queried')
    photo_list = flickr_get_photo_list(search_string, **kwargs)
    url_list   = flickr_get_url_list(photo_list, True)
    open(url_list_fpath,'w').write(repr(url_list))
    flickr_download_url_list(url_list, download_dir)
    baddies = verify_downloads(download_dir)
    delete_baddies(baddies)

def verify_downloads(download_dir):
    from PIL import Image
    fname_list = os.listdir(download_dir)
    fname = fname_list[0]
    baddies = []
    num_checked = 0
    for fname in fname_list:
        _, ext = os.path.splitext(fname)
        if not ext.lower() in ['.jpg','.jpeg','.gif','.tif','.png']:
            continue
        fpath = os.path.join(download_dir, fname)
        try:
            num_checked += 1
            im = Image.open(fpath)
            im.verify()
        except: 
            print(fpath+ ' was bad')
            baddies += [fpath]
    print("Verified %d Downloaded Images. %d Corrupted Files." % (num_checked, len(baddies)))
    return baddies

def delete_baddies(baddies):
    import os
    for bad in baddies: 
        os.remove(bad)

def flickr_get_photo_list(search_string, page_range=(1,-1), api_key=None, secret=None, **kwargs):
    'Queries the FLICKR API for a list of photo xml objects'
    import flickrapi
    #http://www.flickr.com/services/api/flickr.photos.search.html
    # Default Search Prefs
    search_prefs = {
        'sort'             : 'relevance',
        'content_type'     : 1, 
        'media'            : 'photos', 
        'per_page'         : 500,
        'max_tries'        : 5
    }
    # Assign User Search Prefs
    for key, val in kwargs.iteritems():
        search_prefs[key] = val
    # GET API
    flickr = flickrapi.FlickrAPI(api_key, secret=secret, format='etree')
    # Query API Several Times As Needed
    print('Querying Flickr API for: %r' % search_string)
    photo_list = []
    max_trys   = search_prefs['max_tries']
    start_page = page_range[0]
    max_pages  = page_range[1]
    page       = start_page
    while(True):
        try_number = 0
        print('------------------\n')
        while(True):
            try: 
                max_page_str = '?' if max_pages == -1 else str(max_pages)
                print('Query Page: %d / %s' % (page, max_page_str))
                sys.stdout.flush()
                rsp = flickr.photos_search( text=search_string,
                                             page=page,
                                             **search_prefs)
                print('FlickrAPI Status: %r' % rsp.attrib['stat'])
                if not rsp.attrib['stat'] == 'ok': raise Exception('flickrapi status NOT ok')
                photos     = rsp.getchildren()[0]
                sys.stdout.write('Photos Attributes: {')
                for key,val in photos.attrib.iteritems():
                    sys.stdout.write('\n  '+key+' : '+repr(val))
                sys.stdout.write('}\n')
                if max_pages == -1: max_pages = int(photos.attrib['pages'])
                max_page_str = '?' if max_pages == -1 else str(max_pages)
                print('Query Page: %d / %s -- SUCCESS' % (page, max_page_str))
                # Add photos to the list
                photo_list.extend(photos.getchildren())
                page = page + 1
                break
            # Flickr API didnt work
            except Exception as ex: 
                print('Hiccuped : '+str(ex))
                print('Try %d failed' % try_number)
                try_number = try_number + 1
                if try_number > max_trys:
                    print('Max FlickAPI Tries Reached. I give up!')
                    break
                print(' --- Trying Again ---')
                import time
                time.sleep(try_number)
        if page > max_pages: 
            print('Found %d photos in all %d pages' % (len(photo_list), max_pages))
            break
    return photo_list

def flickr_get_url_list(photo_list, fname_bit=False):
    return [flickr_photo2_url(photo, fname_bit) for photo in photo_list]

def flickr_download_url_list(url_list, download_dir):
    'Downloads list of urls to download_dir'
    # Verify Download Location 
    download_dir = download_dir.replace('\\','/')
    if not download_dir[-1] == '/': download_dir = download_dir+'/'
    if os.path.exists(download_dir):
        print("Download Directory Exists: "+download_dir)
    else: 
        print("Make Download Directory: "+download_dir)
        os.mkdir(download_dir)
    # Do Downloads
    total = len(url_list)
    print("Downloading %d photos to " % total, download_dir)
    maxil = str(len(str(total))) #Max int len format
    for count, (img_url, img_fname) in enumerate(url_list):
        sys.stdout.write(('Downloading %'+maxil+'d/%d') % (count+1, total))
        download_img_url(img_url, img_fname, download_dir=download_dir)

def download_img_url(img_url, img_fname, download_dir):
    'downloads photo from FLICKR farm url'
    img_fpath = download_dir+img_fname
    if os.path.exists(img_fpath):
        sys.stdout.write('  --  Already Exists '+img_fname+'\n')
        sys.stdout.flush()
        return True
    else:
        sys.stdout.write('  --  New Image '+img_fname)
        sys.stdout.flush()
    try: 
        img_file = open(img_fpath,'wb')
        img_file.write(urllib.urlopen(img_url).read())
        img_file.close()
        sys.stdout.write('  SUCCESS\n')
        sys.stdout.flush()
    except Exception as ex: 
        sys.stdout.write('  FAILED\n')
        sys.stdout.flush()
        print(ex)
        return False
    return True
    
def flickr_photo2_url(photo, fname_bit=False):
    'Tranforms FLICKR photo xml element to a FLICK URL'
    img_fname = '%(id)s_%(secret)s.jpg' % photo.attrib
    url       = 'http://farm%(farm)s.staticflickr.com/%(server)s/' % photo.attrib
    img_url  = url + img_fname
    if fname_bit:
        return (img_url, img_fname)
    else:
        return img_url

    #content_options = {
        #'photos_only'       : 1, 'screenshots_only'  : 2, 'other_only'   : 3,
        #'photos+screenshots': 4, 'screenshots+other' : 5, 'photos+other' : 6,
        #'all'               : 7 }
    #sort_options = ['date-taken-desc',      'date-taken-asc',
                    #'date-posted-desc',     'date-posted-asc',
                    #'interestingness-desc', 'interestingness-asc',
                    #'relevance']

if __name__ == '__main__':
    main()
