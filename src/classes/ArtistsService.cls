public with sharing class ArtistsService {

    public static Artist__c getArtistFromInside(String artistId) {
        List<Artist__c> artist = [SELECT Name,SpotifyId__c,Favorite__c,BlackList__c,Image__c FROM Artist__c WHERE SpotifyId__c = :artistId];
        return artist.isEmpty() ? new Artist__c() : artist[0];
    }

    public static Artist__c addOrRemoveFav(String artistId) {
        List<Artist__c> artist = [SELECT Name,SpotifyId__c,Favorite__c,BlackList__c,Image__c FROM Artist__c WHERE SpotifyId__c = :artistId];
        if (artist.isEmpty()) {
            SingleArtistWrapper artistWrapper = ConnectSpotify.getArtist(artistId);
            Artist__c newArtist = new Artist__c(Name = artistWrapper.name, SpotifyId__c = artistId, Favorite__c = true,Image__c=artistWrapper.images[0].url);
            insert newArtist;
            return newArtist;
        } else {
            if (artist[0].Favorite__c == true) {
                artist[0].Favorite__c = false;
            } else {
                artist[0].Favorite__c = true;
                artist[0].BlackList__c = false;
            }
            update artist;
            return artist[0];
        }
    }

    public static Artist__c addOrRemoveBlacklist(String artistId) {
        List<Artist__c> artist = [SELECT Name,SpotifyId__c,Favorite__c,BlackList__c,Image__c FROM Artist__c WHERE SpotifyId__c = :artistId];
        if (artist.isEmpty()) {
            SingleArtistWrapper artistWrapper = ConnectSpotify.getArtist(artistId);
            Artist__c newArtist = new Artist__c(Name = artistWrapper.name, SpotifyId__c = artistId, BlackList__c = true,Image__c=artistWrapper.images[0].url);
            insert newArtist;
            return newArtist;
        } else {
            if (artist[0].BlackList__c == true) {
                artist[0].BlackList__c = false;
            } else {
                artist[0].BlackList__c = true;
                artist[0].Favorite__c = false;
            }
            update artist;
            return artist[0];

        }
    }


    public static List<Artist__c> getFavoriteArtists() {
        List<Artist__c> artists = [SELECT Name,SpotifyId__c,Favorite__c,Image__c FROM Artist__c WHERE Favorite__c = true];
        return artists.isEmpty() ? new List<Artist__c>() : artists;
    }


    public static List<Artist__c> getBlackListArtists() {
        List<Artist__c> artists = [SELECT Name,SpotifyId__c,Favorite__c,BlackList__c,Image__c FROM Artist__c WHERE BlackList__c = true];
        return artists.isEmpty() ? new List<Artist__c>() : artists;
    }

    public static Set<String> getBlackListArtistsSpotifyId() {
        List<Artist__c> artists = [SELECT Name,SpotifyId__c,Image__c FROM Artist__c WHERE BlackList__c = true];
        Set<String> artistBlackListIds = new Set<String>();
        for (Artist__c artist : artists) {
            artistBlackListIds.add(artist.SpotifyId__c);
        }
        return artistBlackListIds.isEmpty() ? new Set<String>() : artistBlackListIds;
    }

    public static SingleArtistWrapper convertNoimage(SingleArtistWrapper singleArtistWrapper) {
        if(singleArtistWrapper.images.isEmpty()){
            SingleArtistWrapper.Image image = new SingleArtistWrapper.Image();
            image.url='https://www.securityindustry.org/wp-content/uploads/sites/3/2018/05/noimage.png';
            singleArtistWrapper.images.add(image);
            singleArtistWrapper.images.add(image);
            singleArtistWrapper.images.add(image);
        }
        return singleArtistWrapper;

    }

    public static ArtistWrapper convertNoimage(ArtistWrapper artistWrapper) {
       for(SingleArtistWrapper singleArtistWrapper : artistWrapper.artists.items)
           convertNoimage(singleArtistWrapper);
        return artistWrapper;
    }

}