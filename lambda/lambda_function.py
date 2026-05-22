import json
import boto3
import spotipy
import os
from spotipy.oauth2 import SpotifyClientCredentials
from datetime import datetime

def lambda_handler(event, context):
    client_id = os.environ['SPOTIFY_CLIENT_ID']
    client_secret = os.environ['SPOTIFY_CLIENT_SECRET']
    sp = spotipy.Spotify(auth_manager=SpotifyClientCredentials(
        client_id=client_id,
        client_secret=client_secret
    ))
    queries = [
        "Top hits India 2024",
        "Bollywood hits 2024",
        "Punjabi hits 2024",
        "Telugu hits 2024",
        "Tamil hits 2024",
        "Hindi songs 2024",
        "Arijit Singh hits",
        "Diljit Dosanjh hits",
        "AP Dhillon songs",
        "Shreya Ghoshal songs",
        "Badshah rap songs",
        "Yo Yo Honey Singh",
        "Karan Aujla songs",
        "Sidhu Moosewala",
        "AR Rahman hits",
        "Atif Aslam songs",
        "Neha Kakkar songs",
        "Jubin Nautiyal songs",
        "Tony Kakkar songs",
        "Darshan Raval songs"
    ]
    all_tracks = []
    seen = set()
    for query in queries:
        try:
            results = sp.search(q=query, type="track", limit=10)
            tracks = results["tracks"]["items"]
            for track in tracks:
                track_id = track.get("id", "")
                if track_id not in seen:
                    seen.add(track_id)
                    all_tracks.append({
                        "track_name": track.get("name", ""),
                        "artist": track.get("artists", [{}])[0].get("name", ""),
                        "album": track.get("album", {}).get("name", ""),
                        "popularity": track.get("popularity", 0),
                        "duration_ms": track.get("duration_ms", 0),
                        "release_date": track.get("album", {}).get("release_date", "")
                    })
        except Exception as e:
            print(f"Error for query '{query}': {str(e)}")
            continue
    s3 = boto3.client("s3")
    filename = "spotify-pipeline-raw/spotify_raw_" + str(datetime.now()) + ".json"
    s3.put_object(
        Bucket="de-spotify-pipeline-1377",
        Key=filename,
        Body='\n'.join([json.dumps(track) for track in all_tracks])
    )
    return {
        "status": "success",
        "file": filename,
        "tracks": len(all_tracks)
    }
