# Wordle Decoder

It guesses your guesses based on all those little square emojis that we now love to share.

Given your Wordle share, the decoder will spit back the five-letter words it thinks you played with some degree of confidence.

## Installation

    $ gem install wordle_decoder

## Usage

After installing the gem, run `wordle_decoder` at the command line like so:

    $ wordle_decoder
    
You'll be prompted to share your wordle. Go ahead and paste in your wordle share text. The share text should look something like this:

```
Wordle 258 3/6

⬛⬛🟨⬛🟨
⬛🟩🟩🟩⬛
🟩🟩🟩🟩🟩
```
You'll then be prompted to confirm the word of the day, or if it couldn't figure it out, you'll be asked for it. After that, it'll _try_ to guess your guesses.

## Why?

I wasn't sure if something like this was possible and thought it'd be a fun project to build. It does a pretty good job, at least some of the time... 

---

Enjoy,

[@mattruzicka](https://twitter.com/mattruzicka)
