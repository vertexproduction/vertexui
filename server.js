const express = require('express');
const path = require('path');
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// Mock Database (In-memory array)
// In a production app, you would connect this to MongoDB or SQLite
let ringtones = [
    {
        id: 1,
        title: "Classic Marimba",
        url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
        likes: 12,
        dateAdded: new Date(Date.now() - 86400000 * 2) // 2 days ago
    },
    {
        id: 2,
        title: "Synth Wave Beat",
        url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3",
        likes: 45,
        dateAdded: new Date(Date.now() - 86400000) // 1 day ago
    }
];

// GET: Fetch all ringtones
app.get('/api/ringtones', (req, res) => {
    res.json(ringtones);
});

// POST: Add a new ringtone via the website form
app.post('/api/ringtones', (req, res) => {
    const { title, url } = req.body;

    if (!title || !url) {
        return res.status(400).json({ error: "Title and Audio URL are required." });
    }

    // Basic validation for MP3, MP4, or File.io links
    const isValidSource = url.includes('file.io') || url.endsWith('.mp3') || url.endsWith('.mp4');
    if (!isValidSource) {
        return res.status(400).json({ error: "URL must be an MP3, MP4, or a file.io link." });
    }

    const newRingtone = {
        id: ringtones.length + 1,
        title: title,
        url: url,
        likes: 0,
        dateAdded: new Date()
    };

    ringtones.push(newRingtone);
    res.status(201).json(newRingtone);
});

// POST: Like a ringtone
app.post('/api/ringtones/:id/like', (req, res) => {
    const id = parseInt(req.params.id);
    const ringtone = ringtones.find(r => r.id === id);
    
    if (ringtone) {
        ringtone.likes += 1;
        res.json(ringtone);
    } else {
        res.status(404).json({ error: "Ringtone not found" });
    }
});

app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
