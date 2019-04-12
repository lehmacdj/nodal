Here are a few examples that should be embeddable within the general framework:
- Pokemon type match-up chart
  + need relations for super-effective against
  + fairly simple
  + mostly tests sorting ability of the graph
- Music library/playlists structure
  + need multiple overlapping inclusions
  + playlists/albums
  + duplicity, i.e. repeat songs in albums, for sharing of space
  + however, duplicity should allow data to be modified between copies
  + e.g. same song data in two albums, album art differs between the two
  + this last point is very tricky, and requires interface to MP3 intrinsics,
    that maybe don't make sense to be built in (at least at first)
