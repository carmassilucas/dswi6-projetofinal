<%@page import="service.UserRentService"%>
<%@page import="dto.EditRentRequest"%>
<%@page import="java.util.UUID"%>
<%@page import="java.util.Map"%>
<%@page import="entity.Rent"%>
<%@page import="exception.DateRangeException"%>
<%@page import="java.sql.SQLException"%>
<%@page import="exception.RentAreadyExists"%>
<%@page import="service.RentService"%>
<%@page import="dto.CreateRentRequest"%>
<%@page import="java.time.LocalDateTime"%>
<%@page import="entity.User"%>
<%@page contentType="text/html;charset=UTF-8" language="java" %>

<%
    var sessionUser = session.getAttribute("user");
	User user = null;

    if (sessionUser == null || !(sessionUser instanceof User)) {
    	response.sendRedirect("sign-in.jsp");
    	return;
    }
   	
    user = (User) sessionUser;
    
    if (user.userType() != 2L) {
    	response.sendRedirect("rent.jsp");
    	return;
    }
    
    if (!user.actived()) {
    	session.setAttribute("erro", "Usuário inativo, altere sua senha para ativar.");
    	response.sendRedirect("change-password.jsp");
    	return;
    }
    
    String rentId = request.getParameter("id");
    
    if (rentId == null) {
    	response.sendRedirect("rentals.jsp");
    	return;
    }
    
    Rent rent = RentService.getInstance().findById(UUID.fromString(rentId));
    
    if (rent == null) {
    	response.sendRedirect("rentals.jsp");
    	return;
    }
    
    if (UserRentService.getInstance().existsActivedReservationByRentId(rent.id())) {
    	response.sendRedirect("rentals.jsp");
    	session.setAttribute("erro", "Não é possível alterar, espaço reservado ou reserva já finalizada.");
    	return;
    }
    
    String erro = "";
    
    if (request.getMethod().equalsIgnoreCase("post")) {
    	var dto = new EditRentRequest(
    			rent.id(),
    			request.getParameter("name"),
    			request.getParameter("address"),
    			Long.parseLong(request.getParameter("rent_type")),
    			LocalDateTime.parse(request.getParameter("initial_datetime")),
    			LocalDateTime.parse(request.getParameter("final_datetime")),
    			request.getParameter("description"),
    			rent.createdAt()
		);
		
		try {
			rent = RentService.getInstance().update(dto);
			session.setAttribute("sucesso", "Espaço atualizado com sucesso!");
			response.sendRedirect("rentals.jsp");
			return;
		} catch(DateRangeException e) {
		    erro = e.getMessage();
		}
	}    
    
    Map<Long, String> rentType = Map.of(1L, "Auditório", 2L, "Salão de festas");
    
%>

<!doctype html>
<html lang="pt-br">
	<head>
	    <meta charset="UTF-8">
	    <meta name="viewport" content="width=device-width, initial-scale=1.0">
	    <title>Alterar espaço | Natureza Viva</title>
	    <script src="https://cdn.tailwindcss.com"></script>
	    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
	</head>
	<body class="bg-gray-100 flex flex-col items-center justify-center min-h-screen">
	    <header class="fixed top-0 left-0 w-full bg-white shadow mb-6 z-10">
	        <div class="max-w-6xl mx-auto px-4 py-4 flex items-center justify-between">
	            <div class="flex items-center">
	                <i class="fas fa-leaf text-green-500 mr-2"></i>
	                <h1 class="text-xl font-bold text-green-500">Natureza Viva</h1>
	            </div>
	            <nav class="flex space-x-4">
	                <a href="rentals.jsp" class="font-bold text-zinc-700 hover:text-zinc-950">Espaços</a>
	                <a href="closure.jsp" class="font-bold text-zinc-700 hover:text-zinc-950">Fechamento</a>
	                <a href="open-occurrence.jsp" class="font-bold text-zinc-700 hover:text-zinc-950">Ocorrências</a>
	                <a href="sign-out.jsp" class="font-bold text-rose-600 hover:text-rose-800">Sair</a>
	            </nav>
	        </div>
	    </header>
	
		<form action="<%= request.getRequestURI() %>?id=<%= rent.id() %>" method="post" class="bg-white p-8 rounded-xl shadow-lg space-y-6 max-w-3xl mx-auto" role="form" aria-labelledby="form-title">
		    <h3 id="form-title" class="text-xl font-bold text-center text-green-500 mb-4">Alterar Dados do Espaço</h3>
		
		    <div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
		        <div>
		            <label for="name" class="block text-sm font-semibold text-gray-700">Nome do Espaço</label>
		            <input type="text" id="name" name="name" class="mt-2 w-full p-2 border border-gray-300 rounded-lg" placeholder="Nome do espaço" required value="<%= rent.name() %>"/>
		        </div>
		        <div>
		            <label for="address" class="block text-sm font-semibold text-gray-700">Endereço</label>
		            <input type="text" id="address" name="address" class="mt-2 w-full p-2 border border-gray-300 rounded-lg" placeholder="Endereço do espaço" required value="<%= rent.address() %>" />
		        </div>
		    </div>
		
		    <div class="space-y-4">
		        <div>
		            <label for="rent_type" class="block text-sm font-semibold text-gray-700">Tipo do Espaço</label>
		            <select id="rent_type" name="rent_type" class="mt-2 w-full p-2 border border-gray-300 rounded-lg" required>
		                <option value="" disabled>Selecione um tipo</option>
		                <option value="1" <% if (rent.rentType().equals(1L)) { %> selected <% } %>>Auditório</option>
		                <option value="2" <% if (rent.rentType().equals(2L)) { %> selected <% } %>>Salão de Festas</option>
		            </select>
		        </div>
		        <div>
		            <label for="description" class="block text-sm font-semibold text-gray-700">Descrição</label>
		            <textarea id="description" name="description" class="mt-2 h-32 max-h-32 w-full p-2 border border-gray-300 rounded-lg" placeholder="Detalhes do espaço..."><%= rent.description() %></textarea>
		        </div>
		    </div>
		
		    <div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
		        <div>
		            <label for="initial_datetime" class="block text-sm font-semibold text-gray-700">Data Inicial</label>
		            <input type="datetime-local" id="initial_datetime" name="initial_datetime" class="mt-2 w-full p-2 border border-gray-300 rounded-lg" required value="<%= rent.initialDatetime() %>"/>
		        </div>
		        <div>
		            <label for="final_datetime" class="block text-sm font-semibold text-gray-700">Data Final</label>
		            <input type="datetime-local" id="final_datetime" name="final_datetime" class="mt-2 w-full p-2 border border-gray-300 rounded-lg" required value="<%= rent.finalDatetime() %>"/>
		        </div>
		    </div>
		
			<button type="submit" class="mt-4 bg-green-500 text-white font-semibold py-2 w-full rounded hover:bg-green-600 focus:outline-none focus:ring-2 focus:ring-blue-400 focus:ring-offset-2 text-center" aria-label="Salvar alterações">
				Salvar Alterações
			</button>
		</form>
		
		<% if (!erro.equals("")) { %>
	        <div class="fixed bottom-4 right-4 bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded shadow-lg" role="alert">
	            <strong class="font-bold">Erro:</strong>
	            <span class="block sm:inline"><%= erro %></span>
	        </div>
	    <% } %>
	</body>
</html>



