package com.example.crud_mysql_service.services;

import com.example.crud_mysql_service.models.Card;
import com.example.crud_mysql_service.repositories.CardRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class CardService {
    @Autowired
    private CardRepository cardRepository;

    public List<Card> getAll() {
        return cardRepository.findAll();
    }

    public Card saveCard(Card card) {
        return cardRepository.save(card);
    }

    public List<Card> getCardsByUserId(Long userId) {
        return cardRepository.findByUserId(userId);
    }

    public Card updateCard(Long id, Card cardDetails) {
        Card card = cardRepository.findById(id).orElse(null);
        if (card != null) {
            card.setCardNumber(cardDetails.getCardNumber());
            card.setCardHolderName(cardDetails.getCardHolderName());
            card.setExpirationDate(cardDetails.getExpirationDate());
            card.setCvv(cardDetails.getCvv());
            return cardRepository.save(card);
        }
        return null;
    }

    public void deleteCard(Long id) {
        cardRepository.deleteById(id);
    }

    public Card freezeCard(Long id) {
        Card card = cardRepository.findById(id).orElse(null);
        if (card != null) {
            card.setFrozen(true);
            return cardRepository.save(card);
        }
        return null;
    }

    public Card unfreezeCard(Long id) {
        Card card = cardRepository.findById(id).orElse(null);
        if (card != null) {
            card.setFrozen(false);
            return cardRepository.save(card);
        }
        return null;
    }
}
