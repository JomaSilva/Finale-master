/*

        Documentation on how to use:


    This text is directed at the average developer, in order to work with the engine
    with little to no effort.
    Before we start, you are advised that this is not an in-depth documentation,
    but a small explanation on how to USE the engine.


    For as long as you do not need to tweak any part of the engine, you will mainly use just two procedures:
        _SoundEngine()
        _MusicEngine()

    For the former one, the arguments that may be passed are the following:
            Syntax: _SoundEngine(sound, atom/location, range=1, channel=-1, volume=100, repeat=0, repeat_times=null, interval=10, falloff=range, environment=-1, frequency=0, altitude_var="layer")

            Arguments:
                sound
                    A sound file, passed with single quotes. *Required*

                atom/location
                    A /mob, /obj or /turf, or any other atom in the map from where the sound will appear to come from.
                    If not specified, the sound will be sent to the user.

                range
                    If the sound is a repeated sound (repeat = 1), this value specifies the distance in tiles to stop hearing the sound.

                channel
                    Default: -1
                    If specified, the sound will play on an specific channel.
                    A value of 0 or less takes the first channel available.
                    Recommended: 0 or -1

                volume
                    Default: 100
                    The volume at wich the sound will be played on its center position.


                repeat
                    Default: 0
                    If set to 1, the sound will repeat for each client that received it until either;
                    The client walks out of range, specified by the value of 'range'
                    If repeat_times is set to 0 or higher, sound will be stopped after X times played.

                repeat_times
                    Default: null
                    If set to 0 or higher, and when repeat is set to 1, determines the amount of loops
                    to do before the sound stops.

                interval
                    Default = 10
                    If repeat is set to 1, specifies the time delay between each update on the sound.
                    Recommended: 5 - 15

                falloff
                    Default: range
                    If needed, specifies the falloff distance for the sound.
                    Within the fallof the sound will play at the loudest volume possible, and fades out as you walk away.

                environment
                    Default: -1
                    If specified, applies an environment to the sound.
                    Enviromnets to be applied can bee seen on the DM Reference > environment var (sound)

                frequency
                    Default: 0
                    The frequency to play the sound at.
                    For more information about frequencies, refer to the DM Reference > frequency var (sound)

                altitude_var
                    Default = "layer"
                    A value that represents the altitude of a character respect to the sound,
                    making the sound appear to come from above/below of your character.


        Examples:
            spawn _SoundEngine('MyEffects/Effect1.wav', src)        // Plays a sound effect as if it came from 'src'

            var/sound/sound = _SoundEngine('MyEffects/Effect1.wav', src, range = 4, repeat = 1)
                                    // ^ Plays a sound and repeats it until all players have walked out of range
                                    // ^ Also keeps a reference to the sound so you can manipulate it.
            while(sound)sleep(5)
            world<<"The sound stopped playing"


    Now you know how to launch sound effects, so why not play some background music to put our players
    in position?
    For this purpose we use the _MusicEngine() prodecure;

            Syntax:
                _MusicEngine(sound, client/client, channel=MUSIC_CHANNEL_1, pause=0, repeat=0, wait=0, volume=40, instant = 0, time = 20, increments = 10)

            Arguments:
                sound
                    A sound file, passed with single quotes. *Required*

                client
                    The client who will hear the music. *Required*

                channel
                    Default:  MUSIC_CHANNEL_1
                    This value specifies the channel at which the music will played.
                    This can range from 1 to 4 (MUSIC_CHANNEL_2, MUSIC_CHANNEL_3...)
                    Channels 1 and 2 are binded, so if you play a music in channel 1,
                    and another one is playing on channel 2, the music will fade out
                    and play the channel 1 music.
                    Same happens with channels 3 and 4.

                pause
                    Default: FALSE (0)
                    If set to TRUE (1), the sound will be played on the channel,
                    but will be paused instantly, so it can be resumed later at will.
                    For this purpose, you will need to hold a reference to the actual
                    sound datum. (See example #3)

                repeat
                    Default: FALSE (0)
                    If set to TRUE (1), the sound will be repeated over and over,
                    until explicitly stopping it.

                wait
                    Default: FALSE (0)
                    If set to true, waits for other sounds playing in the same channel
                    to stop before being played.

                volume
                    Default: 40
                    The volume at which the music will be played.
                    Recommended ranges are between 30 and 60 for background music.

                instant
                    Default: FALSE (0)
                    If set to TRUE (1), the sound will play isntantly in the specified channel
                    without waiting or fading out other sounds.

                time
                    Default: 20
                    The time desired, in milliseconds, for the actual music to fade out (if any).

                increments
                    Default: 10
                    The times the sound's volume will be decreased (for playing sounds) and increased (for the new one),
                    until them reaches 0 and [volume] respectively.


            Examples:
                #1) Playing a Background Music:
                    mob/Login()
                        if(client)
                            spawn _MusicEngine('BackgroundMusic.wav', client, MUSIC_CHANNEL_1)
                        ...


                #2) Changing a soundtrack (While playing other):
                        ...
                        _MusicEngine('AnotherSoundtrack.wav', client, MUSIC_CHANNEL_2, time=30)
                                    // ^ We play a sound file on the second channel, and specify that if any sound is being played
                                        on channel one, it will be faded out, and this fade will last 3 seconds. (time / 10)


                #3) Resuming a paused sound:
                    var/sound/_bgsound = _MusicEngine('BackgroundMusic.wav', client, channel=MUSIC_CHANNEL_2, pause=TRUE)
                                // ^ Send a paused sound to the client to the 2nd Channel and hold a reference to the sound.


                    _bgsound.status = SOUND_UPDATE      // Set the sound's status to SOUND_UPDATE so it resumes.
                    src.client << _bgsound              // Resend the sound to the client.
*/