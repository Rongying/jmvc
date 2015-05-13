package com.aug.jmvc.controllers;

import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

@Controller
@RequestMapping("/greeting")
public class GreetingController {

	@RequestMapping(method = RequestMethod.GET)
    public String greeting(ModelMap model) {
        model.addAttribute("name", "JCG Hello World! test");
        return "greeting";
    }

}