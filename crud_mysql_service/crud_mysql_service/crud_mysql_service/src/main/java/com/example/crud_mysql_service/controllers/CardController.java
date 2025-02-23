package com.example.crud_mysql_service.controllers;

import com.example.crud_mysql_service.models.Card;
import com.example.crud_mysql_service.services.CardService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.sql.Date;
import java.sql.Timestamp;
import java.util.Calendar;
import java.util.List;
import java.util.Optional;
import java.util.Random;

//@CrossOrigin(origins = "http://localhost:58381")
@CrossOrigin(origins = "*") // Permitir desde cualquier origen (prueba en desarrollo)
@RestController
@RequestMapping("api/cards")
public class CardController {
    @Autowired
    private CardService cardService;

    @GetMapping
    public List<Card> getAllCards() {
        return cardService.getAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<List<Card>> getCardsByUserId(@PathVariable Long id) {
        List<Card> cards = cardService.getCardsByUserId(id);
        if (!cards.isEmpty()) {
            return ResponseEntity.ok(cards);
        }
        return ResponseEntity.notFound().build();
    }

    @PostMapping
    public ResponseEntity<?> createCard(@RequestBody Card card) {
        List<Card> existingCards = cardService.getCardsByUserId(card.getUserId());

        if (existingCards.size() >= 2) {
            return ResponseEntity.badRequest().body("El usuario ya tiene el máximo de 2 tarjetas.");
        }

        card.setCardNumber(generateCardNumber());
        card.setCvv(generateCVV());
        card.setExpirationDate(generateExpirationDate());

        if (card.getCreatedAt() == null) {
            card.setCreatedAt(new Timestamp(System.currentTimeMillis()));
        }

        Card newCard = cardService.saveCard(card);
        return ResponseEntity.ok(newCard);
    }


    // Método para generar un número de tarjeta de 16 dígitos aleatorios
    private String generateCardNumber() {
        Random random = new Random();
        StringBuilder cardNumber = new StringBuilder();
        for (int i = 0; i < 16; i++) {
            cardNumber.append(random.nextInt(10));  // Añadir un dígito aleatorio
        }
        return cardNumber.toString();
    }

    // Método para generar un CVV de 3 dígitos aleatorios
    private String generateCVV() {
        Random random = new Random();
        int cvv = 100 + random.nextInt(900);  // Generar un número entre 100 y 999
        return String.valueOf(cvv);
    }

    // Método para generar la fecha de expiración (5 años a partir de hoy)
    private Date generateExpirationDate() {
        Calendar calendar = Calendar.getInstance();
        calendar.add(Calendar.YEAR, 5);  // Añadir 5 años a la fecha actual
        java.util.Date expiration = calendar.getTime();
        return new Date(expiration.getTime());
    }

    @PutMapping("/{id}")
    public Card updateCard(@RequestBody Card card, @PathVariable Long id) {
        return cardService.updateCard(id, card);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<List<Card>> deleteCard(@PathVariable Long id) {
        List<Card> cards = cardService.getCardsByUserId(id);
        if (cards != null) {
            cardService.deleteCard(id);
            return ResponseEntity.ok(cards);
        }
        return ResponseEntity.notFound().build();
    }

    @PutMapping("/{id}/freeze")
    public ResponseEntity<Card> freezeCard(@PathVariable Long id) {
        Card card = cardService.freezeCard(id);
        if (card != null) {
            return ResponseEntity.ok(card);
        }
        return ResponseEntity.notFound().build();
    }

    @PutMapping("/{id}/unfreeze")
    public ResponseEntity<Card> unfreezeCard(@PathVariable Long id) {
        Card card = cardService.unfreezeCard(id);
        if (card != null) {
            return ResponseEntity.ok(card);
        }
        return ResponseEntity.notFound().build();
    }
}
