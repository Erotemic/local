
    #search_string = 'smile'
    #username = 'erotemic'
    #flickr = flickrapi.FlickrAPI(api_key, secret=secret, username=username, format='etree')
    #print parse_tree(rsp)
    #print detailed_parse_tree(rsp)

    #TEST: Grab the first photo 
    #photo = photos.getchildren()[0]
    #print photo2_url(photo)

"""
import xml.etree.ElementTree as ET

(token, frob) = flickr.get_token_part_one(perms='read')
if not token: raw_input("Press ENTER after you authorized this program")
    flickr.get_token_part_two((token, frob))

rsp = flickr.photos_search(api_key=api_key, text='amur leopards', sort='relevance')


'''
The URL takes the following format:
http://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}.jpg
	or
http://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}_[mstzb].jpg
	or
http://farm{farm-id}.staticflickr.com/{server-id}/{id}_{o-secret}_o.(jpg|gif|png)
'''

search_string = 'amur leopard'
search_preferences = { 
    'media' : 'videos',
    #'is_commons' : True,
    'per_page' : 100, # max 500
    'page' : 1,
    'privacy_filter' : 1,
    'text' : search_string }
photos = flickr.photos_search(**search_preferences)

geo_tag = 
{
    'has_geo' : True,
    'geo_context' 2 # 0: not defined, 1: indoors, 2: outdoors
}
sets = flickr.photosets_getList()
"""
