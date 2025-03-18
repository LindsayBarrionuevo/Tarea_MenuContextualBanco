package com.example.crud_mysql_service.services;

import com.example.crud_mysql_service.models.User;
import com.example.crud_mysql_service.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UserService {
    @Autowired
    private UserRepository userRepository;
    public List<User> getAll(){
        return userRepository.findAll();
    }

    public User saveUser(User user){
        return (User) userRepository.save(user);
    }

    public Object getUserById(Long id){
        return userRepository.findById(id).orElse(null);
    }

    public User updateUser(Long id, User userDetails){
        User user=(User) userRepository.findById(id).orElse(null);
        if(user!=null)
        {
            user.setPassword_hash(userDetails.getPassword_hash());
            user.setEmail(userDetails.getEmail());
            return (User) userRepository.save(user);
        }
        return null;
    }

    public void deleteUser(Long id){
        userRepository.deleteById(id);
    }


}
