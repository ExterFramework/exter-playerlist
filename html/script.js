const RESOURCE = (typeof GetParentResourceName === 'function')
  ? GetParentResourceName()
  : 'exter-playerlist';

window.addEventListener('message', function (event) {
  const payload = event.data || {};

  switch (payload.type) {
    case 'OPEN':
      openMenu(payload.data || {});
      break;
    case 'CLOSE':
      closeNUI(true);
      break;
    case 'UPDATE':
      update();
      break;
    default:
      break;
  }
});

function trimIdentifier(identifier) {
  if (!identifier || typeof identifier !== 'string') return 'unknown';
  return identifier.length > 12 ? `${identifier.substring(0, 12)}...` : identifier;
}

function playerCard(v) {
  return `
  <div class="online-box">
    <div class="left-box"><i class="fa fa-user" aria-hidden="true"></i></div>
    <div class="right-box"><div class="name">${v.name || 'Unknown'} [${v.id || 0}]</div><div class="steam"><span>${trimIdentifier(v.identifier)}</span></div></div>
  </div>
  `;
}

function openMenu(data) {
  $('body').show();
  $('.online-list').empty();

  const activePlayers = Array.isArray(data.activePlayers) ? data.activePlayers : [];
  const disconnectedPlayers = Array.isArray(data.disconnectedPlayers) ? data.disconnectedPlayers : [];

  $('.onlineplayers').html(`${activePlayers.length}`);
  $('.disconnectedplayers').html(`${disconnectedPlayers.length}`);

  $.each(activePlayers, function (_, v) {
    $('.online-list').append(playerCard(v));
  });
}

function append(variable) {
  $.post(`https://${RESOURCE}/getData`, JSON.stringify({ variable }), function (rows) {
    const list = Array.isArray(rows) ? rows : [];
    $('.online-list').empty();
    $.each(list, function (_, v) {
      $('.online-list').append(playerCard(v));
    });
  });
}

function closeNUI(fromGame = false) {
  $('body').hide();
  if (!fromGame) {
    $.post(`https://${RESOURCE}/close`, JSON.stringify({}));
  }
}

function update() {
  append('online');
}

$(document).on('click', '.online', function () {
  const type = $(this).data('type');
  append(type);

  $('.online').css({
    color: 'rgb(154 87 89)',
    textShadow: '0px 0px 10px rgb(122, 118, 118)',
    backgroundColor: 'rgb(53 54 63)',
    border: 'none',
  });

  $(this).css({
    color: 'rgb(66, 201, 176)',
    textShadow: '0px 0px 10px rgba(66, 201, 176)',
    backgroundColor: 'rgba(10,242,184,0.1)',
    border: '1px solid rgb(42 117 108)',
  });
});

$(document).on('click', '.exit', function () {
  closeNUI();
});

document.addEventListener('keydown', function (event) {
  if (event.key === 'Escape') {
    closeNUI();
  }
});
